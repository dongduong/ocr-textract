class KeyValue < ApplicationRecord
  ## Associations
  belongs_to :accident_invoice, foreign_key: :invoice_id
  has_many :geometry_blocks, as: :entry

  ## Scopes
  scope :at_page,   ->(page) { joins(:geometry_blocks).where(geometry_blocks: {page: page}) }
end
