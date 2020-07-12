class AddRawTextJobToAccidentInvoices < ActiveRecord::Migration[5.1]
  def change
    add_column :accident_invoices, :text_job_id, :string
    add_column :accident_invoices, :text_job_status, :string
  end
end
