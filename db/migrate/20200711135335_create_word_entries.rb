class CreateWordEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :word_entries do |t|
      t.integer :invoice_id
      t.string :value

      t.timestamps
    end
  end
end
