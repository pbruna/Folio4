class AddCurrenyToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :currency, :string, :default => "clp"
    
    add_index :invoices, :currency
  end
end