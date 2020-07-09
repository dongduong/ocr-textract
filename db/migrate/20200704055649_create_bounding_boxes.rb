class CreateBoundingBoxes < ActiveRecord::Migration[5.1]
  def change
    create_table :bounding_boxes do |t|
      t.integer :geometry_block_id
      t.string :top 
      t.string :left
      t.string :width
      t.string :height

      t.timestamps
    end
  end
end
