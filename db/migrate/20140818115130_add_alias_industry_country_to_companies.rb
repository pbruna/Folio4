class AddAliasIndustryCountryToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :alias, :string
    add_column :companies, :industry, :string
    add_column :companies, :country, :string
  end
end
