class AddSuscribersToComment < ActiveRecord::Migration
  def change
    add_column :comments, :account_users_ids, :string
    add_column :comments, :company_users_ids, :string
  end
end