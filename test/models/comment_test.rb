require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  
  def setup
    fake_data
  end
  
  def teardown
    ActionMailer::Base.deliveries = []
    @dte.destroy if @dte
    @invoice.destroy
    @account.destroy
  end
  
  test "should not send email to company if private" do
    message = "Este es el mensaje"
    comment = @invoice.comments.new_from_system({message: message, 
              account_users_ids: @invoice.account_users_ids, company_users_ids: @invoice.company_users_ids,
              private: true})
    comment.save
    assert(!comment.subscribers_emails.include?(@contact.email), "No deberia enviarse correo al cleinte")
  end
  
  test "Comment from system with email" do
    message = "Este es el mensaje"
    comment = @invoice.comments.new_from_system({message: message, account_users_ids: @invoice.account_users_ids, private: true})
    assert(comment.save, "Failure message.")
    assert_equal(message, comment.message)
    mail = ActionMailer::Base.deliveries.last
    assert_not_nil(mail)
    assert_equal(@user.email, mail['to'].to_s)
  end
  
end
