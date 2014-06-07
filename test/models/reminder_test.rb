require 'test_helper'

class ReminderTest < ActiveSupport::TestCase

  def setup
  end

  def teardown
  end

  test "Default reminder should be one week and tuesday before" do
    date = Date.parse("2014-06-16")
    reminder = Reminder.new(due_date: date, subject: "Nada")
    reminder.save
    assert_equal("2014-06-10", reminder.notification_date.to_s)
    date = Date.parse("2014-05-18")
    reminder = Reminder.new(due_date: date, subject: "Nada")
    reminder.save
    assert_equal("2014-05-06", reminder.notification_date.to_s)
    date = Date.parse("2014-05-20")
    reminder = Reminder.new(due_date: date, subject: "Nada")
    reminder.save
    assert_equal("2014-05-13", reminder.notification_date.to_s)
  end

  test "Reminder shoud be set to date minus the days passed" do
    date = Date.parse("2013-03-03")
    reminder = Reminder.new(due_date: date, notification_days: 5, subject: "Nada")
    assert reminder.save
    assert_equal("2013-02-26", reminder.notification_date.to_s)
  end
  
  test "default value for active  is false" do
    date = Date.parse("2013-03-03")
    reminder = Reminder.new(due_date: date, notification_days: 5, subject: "Nada")
    assert reminder.save
    assert(!reminder.active?, "Failure message")
  end

end