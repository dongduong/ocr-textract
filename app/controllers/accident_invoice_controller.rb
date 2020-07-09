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

      redirect_to accident_invoice_index_path, notice: 'Invoices are created Susscessful'
    end
  rescue StandardError => e
    puts e.message
    redirect_to accident_invoice_index_path, error: 'Failed to create new Invoices'
  end

  def show
    @invoice = AccidentInvoice.find(params[:id])
    get_analyse_result unless @invoice.extract_finish?
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

    PdfMerger.new(@invoice).perform
  end
end
