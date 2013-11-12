class ChangeInvoiceCustomerColumnName < ActiveRecord::Migration
  def change
    rename_column :invoices, :customer_id, :company_id
  end
end
