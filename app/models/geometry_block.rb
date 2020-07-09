class GeometryBlock < ApplicationRecord
  belongs_to :entry, polymorphic: true
  has_one :bounding_box, foreign_key: :geometry_block_id
end
