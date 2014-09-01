class FixScaleOffInvoices < ActiveRecord::Migration
  def change
    change_column :invoices, :original_currency_total, :decimal, precision: 20, scale: 4, default: 0
    change_column :invoice_items, :price, :decimal, precision: 15, scale: 4, default: 0
    change_column :invoice_items, :total, :decimal, precision: 15, scale: 4, default: 0
  end
end