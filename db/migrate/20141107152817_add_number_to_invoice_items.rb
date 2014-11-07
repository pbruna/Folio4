class AddNumberToInvoiceItems < ActiveRecord::Migration
  def change
    add_column :invoice_items, :number, :integer, default: 1
  end
end