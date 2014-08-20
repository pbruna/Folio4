class ChangePriceTotalInvoiceItems < ActiveRecord::Migration
  def change
    change_column :invoice_items, :price, :decimal, default: 0.0
    change_column :invoice_items, :total, :decimal, default: 0.0
  end
end