class AddActiveToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :active, :boolean, default: false
  end
end