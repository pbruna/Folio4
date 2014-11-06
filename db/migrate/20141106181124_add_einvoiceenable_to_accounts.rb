class AddEinvoiceenableToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :e_invoice_enabled, :boolean, default: false
  end
end