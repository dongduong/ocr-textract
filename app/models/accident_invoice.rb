class AccidentInvoice < ApplicationRecord
  has_attached_file :invoice,
                    styles: lambda { |attachment|
                      attachment.instance.invoice.content_type.index("image/") == 0 ?
                      {
                        original: '',
                        small: '186x>', medium: '700x800>'
                      } :
                      {}
                    },
                    source_file_option: { all: '-auto-orient' }
  validates_attachment :invoice, presence: true,
                               content_type: { content_type: [/\Aimage\/.*\Z/, 'application/pdf'] }

  ## Associations
  has_many :key_values, foreign_key: :invoice_id
  has_many :table_entries, foreign_key: :invoice_id

  def extract_finish?
    job_status != 'IN_PROGRESS'
  end

  def highlight_url
    "/files/invoice_highlight/#{job_id}.pdf"
  end
end
