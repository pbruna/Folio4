class ModifyInvoiceItemTotalAmount < ActiveRecord::Migration
  def change
    rename_column :invoice_items, :total_amount, :total
    change_column_default :invoice_items, :total, 0
    
    change_column_default :invoice_items, :price, 0
    change_column_default :invoice_items, :quantity, 0
  end
end