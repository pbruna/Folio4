class ModifyInvoiceNumberDefault < ActiveRecord::Migration
  def change
  	change_column_default(:invoices, :number, nil)
  end
end
