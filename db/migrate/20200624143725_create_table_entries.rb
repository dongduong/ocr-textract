class CreateTableEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :table_entries do |t|
      t.integer :invoice_id
      t.integer :row_count
      t.integer :column_count

      t.timestamps
    end
  end
end
