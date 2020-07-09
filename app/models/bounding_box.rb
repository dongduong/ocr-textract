class BoundingBox < ApplicationRecord
  belongs_to :geometry_block, foreign_key: :geometry_block_id
end
