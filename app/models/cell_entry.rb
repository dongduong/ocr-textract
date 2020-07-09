class CellEntry < ApplicationRecord
  ## Associations
  belongs_to :table_entry, foreign_key: :table_entry_id
  has_one :geometry_block, as: :entry

  ## Scopes
  scope :at_page,   ->(page) { joins(:geometry_block).where(geometry_blocks: {page: page}) }
end
