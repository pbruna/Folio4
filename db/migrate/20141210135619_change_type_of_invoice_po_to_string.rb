class ChangeTypeOfInvoicePoToString < ActiveRecord::Migration
  def change
    change_column :invoices, :po_number, :string
  end
end