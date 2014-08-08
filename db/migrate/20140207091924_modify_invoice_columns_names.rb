class ModifyInvoiceColumnsNames < ActiveRecord::Migration
  def change
    rename_column :invoices, :total_amount, :total
    rename_column :invoices, :net_amount, :net_total
    rename_column :invoices, :tax_amount, :tax_total
    add_column :invoices, :currency_convertion_rate, :float, default: 1
  end
end