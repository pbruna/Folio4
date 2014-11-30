class AddFieldsToDteForNc < ActiveRecord::Migration
  def change
    add_column :dtes, :cod_ref, :integer
    add_column :dtes, :razon_ref, :string
  end
end