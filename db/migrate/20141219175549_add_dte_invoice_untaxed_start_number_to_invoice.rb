class AddDteInvoiceUntaxedStartNumberToInvoice < ActiveRecord::Migration
  def change
    add_column :accounts, :dte_invoice_untaxed_start_number, :integer
  end
end