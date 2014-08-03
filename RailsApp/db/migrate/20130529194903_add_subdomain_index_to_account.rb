class AddSubdomainIndexToAccount < ActiveRecord::Migration
  def change
    add_index :accounts, :subdomain
  end
end
