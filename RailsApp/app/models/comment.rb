class Comment < ActiveRecord::Base
  attr_accessor :notify_account_users
  belongs_to :commentable, polymorphic: true
  belongs_to :author, polymorphic: true
  
  after_create :notify
  
  validates_presence_of :message, :author_type, :author_id, :commentable_id, :commentable_type
  
  
  def author_name
    author.name
  end
  
  def contacts_emails
    account_emails
  end
  
  def account_emails
    commentable.account.users_emails_array
  end
  
  
  def notification_email_subject
    object = commentable
    object_name = commentable.class.model_name.human.titleize # Translated
    "[Nuevo Comentario] #{object_name} ##{object.number} - #{object.subject}"
  end
  
  private
  
  def notify
    return unless notify_account_users
    CommentMailer.delay.comment_notification(id)
  end
  
end
