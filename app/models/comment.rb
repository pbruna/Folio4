require "base64"

class Comment < ActiveRecord::Base
  attr_accessor :notify_account_users
  belongs_to :commentable, polymorphic: true
  belongs_to :author, polymorphic: true
  serialize :account_users_ids
  serialize :company_users_ids
  
  after_create :notify
  
  validates_presence_of :message, :author_type, :author_id, :commentable_id, :commentable_type
  
  
  def account
    author.account
  end
  
  def account_suscribers
    return [] if account_users_ids.nil?
    User.find account_users_ids
  end
  
  def author_name
    return author.email if author.name.nil?
    author.name
  end
  
  def commentable_contact
    commentable.contact
  end
  
  def contacts_emails
    account_emails
  end
  
  def company_suscribers
    return [] if company_users_ids.nil?
    Contact.find company_users_ids
  end
  
  def email_reply_to
    # lo que va despues del arroba
    host = "app.folio.cl"
    mailbox = "#{object_name}-#{commentable.id}-#{encoded_account_id}"
    "#{mailbox}@#{host}"
  end
  
  def object_name
    commentable.class.to_s.downcase
  end
  
  def account_id
    commentable.account_id
  end
  
  def account_emails
    commentable.account.users_emails_array
  end
  
  def default_suscribers
    [author, commentable_contact]
  end
  
  def encoded_account_id
    Base64.strict_encode64(account_id.to_s)
  end
  
  def last_comment
    commentable.comments.last
  end
  
  def last_commentable_suscribers
    return suscribers if last_comment.nil?
    last_comment.suscribers
  end
  
  def suscribers
    list = account_suscribers + company_suscribers
    return default_suscribers if list.empty?
    list
  end
  
  def notification_email_subject
    object = commentable
    object_name = commentable.class.model_name.human.titleize # Translated
    "[Nuevo Comentario] #{object_name} ##{object.number} - #{object.subject} - #{object.company.name}"
  end
  
  private
  
  def notify
    return unless notify_account_users
    CommentMailer.delay.comment_notification(id)
  end
  
end
