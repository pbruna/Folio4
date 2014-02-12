class AddOriginalCurrencyTotalToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :original_currency_total ,:decimal, default: 0.0
  end
end