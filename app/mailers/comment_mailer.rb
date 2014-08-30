class CommentMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  layout 'mailer_default'
  
  def comment_notification(comment_id)
    @comment = Comment.find(comment_id)
    @account = @comment.account
    from = "#{@comment.author_name} <#{ActionMailer::Base.default[:from]}> "
    mail(to: @comment.subscribers_emails, subject: @comment.notification_email_subject,
        reply_to: @comment.email_reply_to, from: from)
  end
  
end
