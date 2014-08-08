class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
	  t.date :notification_date
      t.references :remindable, polymorphic: true
      t.boolean :sent

      t.timestamps

    end
  end
end
