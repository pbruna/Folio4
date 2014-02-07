class ModifyInvoiceItemType < ActiveRecord::Migration
  def change
    remove_column :invoice_items, :product_id
    add_column :invoice_items, :type, :string
    
    add_index :invoice_items, :type
  end
end