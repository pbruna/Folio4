class AddEInvoiceResolutionNumberToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :e_invoice_resolution_number, :integer
  end
end