class Reminder < ActiveRecord::Base
	belongs_to :remindable, polymorphic: true
  serialize :account_users_ids
  serialize :company_users_ids

	before_save :set_notification_date
  before_validation :check_subject 
  
  validate :presence_of_notificable_users
  
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
  
  def contacts_emails
    emails = Array.new
    emails = account_emails + company_emails
  end
  
  def account_emails
    emails = Array.new
    emails = account_users_ids.map {|id| User.find(id).email }
    emails
  end
  
  def company_emails
    emails = Array.new
    emails = company_users_ids.map {|id| Contact.find(id).email }
    emails
  end
  
  def schedule!
    self.active = true
    self.save
    ReminderMailer.delay(run_at: notification_time).invoice_due_notification(id)
  end
  
  # Will be the 9:00 am
  def notification_time
    notification_date.to_time + (3600 * 9)
  end
  
  private
  def set_notification_date
    return unless notification_date.nil?
    self.notification_date = calc_notification_date
  end
  
  def check_subject
    self.subject = "Aviso de vencimiento factura" if subject.blank?
  end
  
  # El Reminder debe tener algun contacto que notificar
  def presence_of_notificable_users
    return unless active?
    return unless (account_users_ids.nil? || company_users_ids.nil?)
    errors.add("Contacto", "Debe tener algún contacto a quien enviar el recordatorio")
  end

end