class PdfMerger
  def initialize(invoice)
    @invoice = invoice
    @invoice_url = "http:#{invoice.invoice.url}"
    @invoice_file_path = "public/files/invoices/#{invoice.job_id}.pdf"
  end

  def perform
    download_from_s3
    highlight_service = Prawn::DocumentHighlight.new(@invoice)
    pdf = CombinePDF.load @invoice_file_path

    for page in 1..@invoice.total_pages
      highlight_service.generate_on_page(page)
      highlight = CombinePDF.load(highlight_service.file_path).pages[0]
      pdf.pages[page-1] << highlight
      highlight_service.remove_file
    end

    # highlight_service = Prawn::DocumentHighlight.new(@invoice)
    # highlight_service.generate
    # highlight = CombinePDF.load(highlight_service.file_path).pages[0]
    # pdf = CombinePDF.load @invoice_file_path
    # pdf.pages.first << highlight

    pdf.save "public/files/invoice_highlight/#{@invoice.job_id}.pdf"
    @invoice.update_column(:can_show_highlight, true)
  end


  def download_from_s3
    open(@invoice_url) do |image|
      File.open(@invoice_file_path, "wb") do |file|
        file.write(image.read)
      end
    end
  end
end
