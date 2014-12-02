class AddDteStartNumbersToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :dte_nc_start_number, :integer, default: 0
    add_column :accounts, :dte_invoice_start_number, :integer, default: 0
  end
end