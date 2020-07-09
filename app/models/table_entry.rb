class TableEntry < ApplicationRecord
  ## Associations
  belongs_to :accident_invoice, foreign_key: :invoice_id
  has_many :cell_entries, foreign_key: :table_entry_id
end
