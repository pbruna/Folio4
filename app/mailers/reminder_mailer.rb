class ReminderMailer < ActionMailer::Base
  layout 'mailer_default'
  
  def invoice_due_notification(reminder_id)
    @reminder = Reminder.find(reminder_id, include: [:remindable])
    @invoice = @reminder.remindable
    @invoice_contact = @invoice.contact
    @account = @invoice.account
    mail(to: @reminder.contacts_emails, subject: @reminder.subject)
  end
  
end
