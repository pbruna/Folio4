class AddColumnsToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :notification_days, :integer
    add_column :reminders, :due_date, :date
    add_column :reminders, :subject, :string
    add_column :reminders, :message, :text
    
    add_index :reminders, :remindable_id
  end
end