class AddUsersToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :account_users_ids, :text
    add_column :reminders, :company_users_ids, :text
  end
end