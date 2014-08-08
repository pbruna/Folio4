class RenameComanyIdToAccountIdUsers < ActiveRecord::Migration
  def change
    rename_column :users, :company_id, :account_id
  end
end