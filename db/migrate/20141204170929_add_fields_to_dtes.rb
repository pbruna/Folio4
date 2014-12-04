class AddFieldsToDtes < ActiveRecord::Migration
  def change
    add_column :dtes, :contacto, :string
    add_column :dtes, :cond_pago, :string
  end
end