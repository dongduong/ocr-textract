class InvoiceAnalyzer
  attr_accessor :vin, :invoice_number, :plate

  INVOICE_NUMBER_KEYS = [
    'Ordnungsnummer',
    'Rechnung-Nr',
    'Rechnung'
  ]

  VIN_KEYS = [
    'VIN',
    'Fg-Nr'
  ]

  PLATE_KEYS = [
    'Amtliches Kennzei',
    'Amtliches Kennzeichen',
    'Amtl. Kennzeichen',
    'Auftrag'
  ]

  def initialize(accident_invoice, run_in_background=true)
    @invoice = accident_invoice
    @vin = nil
    @invoice_number = nil
    @plate = nil
    @run_in_background = run_in_background
    @service = Ocr::Textract.new(file_path, @run_in_background)
    @service_text = Ocr::Textract.new(file_path, @run_in_background)
  end

  def perform
    return unless text_job_id = @service.detect_document_text_async
    save_text_job_to_invoice(text_job_id)

    return unless job_id = @service.analyze_document_async
    save_job_to_invoice(job_id)

    unless @run_in_background
      store_all_text
      store_all_data
      extract_data
    end
  end

  def get_results
    if @service.get_analyze_document(@invoice.job_id)
      @invoice.update_columns(job_status: @service.job_status, total_pages: @service.metadata.pages)
      store_all_data
      extract_data
    end
  end

  def get_document_text_results
    if @service_text.get_document_text(@invoice.text_job_id)
      @invoice.update_column(:text_job_status, @service_text.job_status)
      store_all_text
    end
  end

  private

  def store_all_data
    #store all key_values
    @service.store_all_key_values(@invoice)

    #store all tables
    @service.store_all_table(@invoice)
  end

  def store_all_text
    @service_text.store_all_words(@invoice)
  end

  def extract_data
    INVOICE_NUMBER_KEYS.each do |key|
      if value = @service.find_by_key(key)
        @invoice_number = value
        break
      end
    end

    VIN_KEYS.each do |key|
      if value = @service.find_by_key(key)
        @vin = value
        break
      end
    end

    PLATE_KEYS.each do |key|
      if value = @service.find_by_key(key)
        @plate = value
        break
      end
    end
  end

  def save_job_to_invoice(job_id)
    @invoice.job_id = job_id
    @invoice.job_status = "IN_PROGRESS"
    @invoice.save
  end

  def save_text_job_to_invoice(text_job_id)
    @invoice.text_job_id = text_job_id
    @invoice.text_job_status = "IN_PROGRESS"
    @invoice.save
  end

  def file_path
    "mc-orc-demo/invoice/#{@invoice.id}/#{@invoice.invoice_file_name}"
  end
end
