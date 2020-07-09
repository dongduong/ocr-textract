class AddCanShowHighlightToAccidentInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :accident_invoices, :can_show_highlight, :boolean, default: false
  end
end
