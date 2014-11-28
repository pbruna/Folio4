class AddIndustryCodeToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :industry_code, :integer
  end
end