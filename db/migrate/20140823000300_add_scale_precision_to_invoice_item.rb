class AddScalePrecisionToInvoiceItem < ActiveRecord::Migration
  def change
    change_column :invoice_items, :price, :decimal, precision: 15, scale: 2, default: 0
    change_column :invoice_items, :total, :decimal, precision: 15, scale: 2, default: 0
  end
end