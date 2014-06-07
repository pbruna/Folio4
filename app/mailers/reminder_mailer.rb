class ReminderMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def invoice_due_notification(user)
    @user = user
    mail(to: @user.mail, subject: "notification")
  end
  
end
