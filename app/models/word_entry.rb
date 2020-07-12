class WordEntry < ApplicationRecord
  ## Associations
  belongs_to :accident_invoice, foreign_key: :invoice_id
  has_one :geometry_block, as: :entry

  ## Scopes
  scope :at_page,   ->(page) { joins(:geometry_block).where(geometry_blocks: {page: page}) }
end
