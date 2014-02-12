class AddTotalPayedToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :total_payed, :decimal, default: 0.0
  end
end