class FixCompaniesTable < ActiveRecord::Migration
  def change
    remove_column :companies, :subdomain
    remove_column :companies, :owner_id
    remove_column :companies, :plan_id
    add_column :companies, :rut, :string
    add_column :companies, :address, :string
    add_column :companies, :city, :string
    add_column :companies, :province, :string
    add_column :companies, :phone, :string
    add_column :companies, :industry, :string
    
    add_index :companies, :rut
    add_index :companies, :name
  end
end