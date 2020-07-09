class AddTotalPagesToAccidentInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :accident_invoices, :total_pages, :integer, default: 1
  end
end
