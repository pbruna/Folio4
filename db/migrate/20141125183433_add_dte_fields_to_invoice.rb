class AddDteFieldsToInvoice < ActiveRecord::Migration
  def change
    add_column :dtes, :processed, :boolean
    add_column :dtes, :error_log, :text
  end
end