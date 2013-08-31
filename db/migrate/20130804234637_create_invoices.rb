class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :number, :default => 0
      t.decimal  "tax_amount",         :default => 0.0
      t.decimal  "net_amount",         :default => 0.0
      t.decimal  "total_amount",       :default => 0.0
      t.integer  "customer_id"
      t.integer  "contact_id"
      t.integer  "account_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "taxed"
      t.date     "due_date"
      t.date     "open_date"
      t.date     "close_date"
      t.string   "subject"
      t.integer  "tax_id"
      t.string   "tax_name"
      t.float    "tax_rate"

      t.timestamps
    end
    
    add_index :invoices, :customer_id
    add_index :invoices, :contact_id
    add_index :invoices, :account_id
    add_index :invoices, :tax_id
  end
end
