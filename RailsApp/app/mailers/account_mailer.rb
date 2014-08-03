class AccountMailer < ActionMailer::Base
  layout 'mailer_default'

  def register_welcome(user_id)
    @user = User.find(user_id)
    @account = @user.account
    mail to: @user.email, subject: "Bienvenido a Folio"
  end
end
