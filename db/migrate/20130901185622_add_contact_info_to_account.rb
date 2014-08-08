class AddContactInfoToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :rut, :string
    add_column :accounts, :address, :string
    add_column :accounts, :city, :string
    add_column :accounts, :phone, :string
    add_index :accounts, :rut
  end
end