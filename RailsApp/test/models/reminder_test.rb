require 'test_helper'

class ReminderTest < ActiveSupport::TestCase

  def setup
    date = Date.parse("2014-06-16")
    @reminder = Reminder.new(due_date: date, notification_days: 5, subject: "Nada")
    @reminder.company_users_ids = [1]
    @reminder.account_users_ids = [2]
  end

  def teardown
    @reminder.destroy
  end

  test "Default reminder should be one week and tuesday before" do
    @reminder.notification_days = nil
    @reminder.save
    assert_equal("2014-06-10", @reminder.notification_date.to_s)
  end
  
  test "Default reminder when due date is Sunday should be previous Tues" do
    @reminder.notification_days = nil
    @reminder.due_date = Date.parse("2014-05-18")
    @reminder.save
    assert_equal("2014-05-06", @reminder.notification_date.to_s)
  end
  
  test "Default reminder when due date is Tues should be previous Tues" do
    @reminder.notification_days = nil
    @reminder.due_date = Date.parse("2014-05-20")
    @reminder.save
    assert_equal("2014-05-13", @reminder.notification_date.to_s)
  end

  test "Reminder shoud be set to date minus the days passed" do
    @reminder.due_date = Date.parse("2013-03-03")
    assert @reminder.save
    assert_equal("2013-02-26", @reminder.notification_date.to_s)
  end
  
  test "default value for active  is false" do
    @reminder.due_date = Date.parse("2013-03-03")
    assert @reminder.save
    assert(!@reminder.active?, "Failure message")
  end

end