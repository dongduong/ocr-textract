class CreateAccidentInvoices < ActiveRecord::Migration[5.1]
  def change
    create_table :accident_invoices do |t|
      t.string :name
      t.attachment :invoice

      t.string :invoice_number
      t.string :vin
      t.string :plate

      t.timestamps
    end
  end
end
