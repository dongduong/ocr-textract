class CreateCellEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :cell_entries do |t|
      t.integer :table_entry_id
      t.string :value
      t.integer :row_index
      t.integer :column_index

      t.timestamps
    end
  end
end
