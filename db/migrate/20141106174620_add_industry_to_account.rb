class AddIndustryToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :industry, :string, default: ""
  end
end