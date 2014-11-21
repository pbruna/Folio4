class AddEInvoiceFieldsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :e_invoice_resolution_date, :date
    add_column :accounts, :e_invoice_regional_address, :string
  end
end