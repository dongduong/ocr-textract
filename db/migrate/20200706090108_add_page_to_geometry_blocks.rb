class AddPageToGeometryBlocks < ActiveRecord::Migration[5.1]
  def change
    add_column :geometry_blocks, :page, :integer
  end
end
