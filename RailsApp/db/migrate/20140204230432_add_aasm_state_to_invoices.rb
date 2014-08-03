class AddAasmStateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :aasm_state, :string, default: "draft"
    
    add_index :invoices, :aasm_state
  end
end