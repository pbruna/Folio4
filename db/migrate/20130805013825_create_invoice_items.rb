class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.integer  "account_id"
      t.integer  "product_id"
      t.integer  "quantity"
      t.text     "description"
      t.integer  "price"
      t.integer  "total_amount",                      :default => 0
      t.integer  "invoice_id"
      t.datetime "created_at"
      t.datetime "updated_at"

      t.timestamps
    end
    
    add_index :invoice_items, :account_id
    add_index :invoice_items, :product_id
    add_index :invoice_items, :invoice_id 
  end
end
