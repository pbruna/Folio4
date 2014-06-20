class UserMailer < ActionMailer::Base
  layout 'mailer_default'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome_email.subject
  #
  def welcome_email(user_id, token)
    @token = token
    @user = User.find(user_id)
    @account = @user.account
    @account_owner = @user.account_owner
    mail to: @user.email, subject: "Bienvenido a la cuenta Folio de #{@account.name}"
  end
end
