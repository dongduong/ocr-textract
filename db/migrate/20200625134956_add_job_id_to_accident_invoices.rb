class AddJobIdToAccidentInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :accident_invoices, :job_id, :string
    add_column :accident_invoices, :job_status, :string
  end
end
