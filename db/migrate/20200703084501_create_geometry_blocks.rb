class CreateGeometryBlocks < ActiveRecord::Migration[5.1]
  def change
    create_table :geometry_blocks do |t|
      t.integer :entry_id
      t.string :entry_type
      t.string :entity_type

      t.timestamps
    end
  end
end
