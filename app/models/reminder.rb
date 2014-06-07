class Reminder < ActiveRecord::Base
	belongs_to :remindable, polymorphic: true

	before_save :set_notification_date
  before_validation :check_subject 
	validates_presence_of  :subject
  
	# if days for reminder is not set
	# the default notification date will be the nearest tuesday of the before week
  	def calc_notification_date
		return default_notification_date if notification_days.nil?
		due_date.days_ago(notification_days)
	end

	def default_notification_date
		one_week_ago_date = due_date.last_week
		case one_week_ago_date.wday
		when 0
			notification_date = one_week_ago_date.monday + 8
		when 1
			notification_date = one_week_ago_date + 1
		when 2
			notification_date = one_week_ago_date
		else
			notification_date = one_week_ago_date - (one_week_ago_date.days_to_week_start - 1 )
		end
	end
  
  def schedule!
    self.active = true
    self.save
    #ReminderMailer.delay.invoice_due_notification(invoice.company.owner)
  end
  
  private
  def set_notification_date
    self.notification_date = calc_notification_date
  end
  
  def check_subject
    self.subject = "Aviso de vencimiento factura" if subject.blank?
  end

end