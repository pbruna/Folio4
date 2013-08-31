class ChangeUserEmailIndex < ActiveRecord::Migration
  def change
    remove_index :users, :email
    add_index :users, [:email, :account_id], :unique => true
  end
end
