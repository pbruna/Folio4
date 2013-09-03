class AddCountryIntoAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :country, :string
  end
end