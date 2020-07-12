class AccidentInvoiceController < ApplicationController
  def index
    @invoices = AccidentInvoice.all
  end

  def new
    @invoice = AccidentInvoice.new
  end

  def create
    invoices_ids = []

    ActiveRecord::Base.transaction do
      params[:invoices]["invoice"].each do |invoice|
        accident_invoice = AccidentInvoice.new(invoice_params)
        accident_invoice.invoice = invoice
        accident_invoice.save
        invoices_ids << accident_invoice.id
      end

      #start background job to analyse invoices
      #AnalyseInvoicesWorker.analyse_invoices(invoices_ids) unless invoices_ids.blank?

      analyse_invoices(invoices_ids) unless invoices_ids.blank?

      if invoices_ids.count == 1
        invoice = AccidentInvoice.find_by_id(invoices_ids.first)
        redirect_to accident_invoice_path(invoice), notice: 'Invoice was created susscessful'
      else
        redirect_to accident_invoice_index_path, notice: 'Invoices were created susscessful'
      end
    end
  rescue StandardError => e
    puts "==================================="
    puts e.message
    puts "==================================="
    redirect_to accident_invoice_index_path, error: 'Failed to create new Invoices'
  end

  def show
    @invoice = AccidentInvoice.find(params[:id])
    get_analyse_result unless @invoice.extract_finish?
    get_document_text_result unless @invoice.get_raw_text_finish?
    PdfMerger.new(@invoice).perform unless @invoice.can_show_highlight?
  end

  def destroy
    @invoice = AccidentInvoice.find(params[:id])

    @invoice.destroy
    if @invoice.destroyed?
      flash[:notice] = "Invoice was deleted successfully"
    else
      flash[:error] = "Failed to delete Invoice"
    end
  end

  private

  def analyse_invoices(invoice_ids)
    invoice_ids.each do |id|
      invoice = AccidentInvoice.find(id)
      analyse_invoice(invoice) if invoice
    end
  end

  def analyse_invoice(invoice)
    analyzer = InvoiceAnalyzer.new(invoice)
    analyzer.perform
    invoice.invoice_number = analyzer.invoice_number if analyzer.invoice_number
    invoice.vin = analyzer.vin if analyzer.vin
    invoice.plate = analyzer.plate if analyzer.plate
    invoice.save
  end

  def invoice_params
    params.require(:accident_invoice).permit(:name)
  end

  # def analyse_invoice(invoice)
  #   analyzer = InvoiceAnalyzer.new(invoice)
  #   analyzer.perform
  #   invoice.invoice_number = analyzer.invoice_number if analyzer.invoice_number
  #   invoice.vin = analyzer.vin if analyzer.vin
  #   invoice.plate = analyzer.plate if analyzer.plate
  #   invoice.save
  # end

  def get_analyse_result
    analyzer = InvoiceAnalyzer.new(@invoice)
    analyzer.get_results

    @invoice.invoice_number = analyzer.invoice_number if analyzer.invoice_number
    @invoice.vin = analyzer.vin if analyzer.vin
    @invoice.plate = analyzer.plate if analyzer.plate
    @invoice.save
  end

  def get_document_text_result
    analyzer = InvoiceAnalyzer.new(@invoice)
    analyzer.get_document_text_results
  end
end
