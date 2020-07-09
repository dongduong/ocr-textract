class AnalyseInvoicesWorker
  include Sidekiq::Worker

  def perform(invoice_ids)
    invoice_ids.each do |id|
      invoice = AccidentInvoice.find(id)
      analyse_invoice(invoice) if invoice
    end
  end

  private

  def analyse_invoice(invoice)
    analyzer = InvoiceAnalyzer.new(invoice)
    analyzer.perform
    invoice.invoice_number = analyzer.invoice_number if analyzer.invoice_number
    invoice.vin = analyzer.vin if analyzer.vin
    invoice.plate = analyzer.plate if analyzer.plate
    invoice.save
  end
end
