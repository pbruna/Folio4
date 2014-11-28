class AddPoNumberToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :po_number, :integer
  end
end