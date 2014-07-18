class CommentMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  layout 'mailer_default'
  
  def comment_notification(comment_id)
    @comment = Comment.find(comment_id)
    mail(to: @comment.contacts_emails, subject: @comment.notification_email_subject)
  end
  
end
