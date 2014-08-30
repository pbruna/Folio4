require "base64"

class Comment < ActiveRecord::Base
  attr_accessor :subscribers_ids
  
  belongs_to :commentable, polymorphic: true
  belongs_to :author, polymorphic: true
  serialize :account_users_ids
  serialize :company_users_ids
  
  after_create :notify
  before_create :set_subscribers
  
  validates_presence_of :message, :author_type, :author_id, :commentable_id, :commentable_type
  
  
  def account
    commentable.account
  end
  
  def company
    return nil if commentable.company.nil?
    commentable.company
  end
  
  def account_subscribers
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
  
  def company_subscribers
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
  
  def default_subscribers
    [author, commentable_contact]
  end
  
  def encoded_account_id
    Base64.strict_encode64(account_id.to_s)
  end
  
  def last_comment
    commentable.comments.last
  end
  
  def last_commentable_subscribers
    return default_subscribers if last_comment.nil?
    last_comment.subscribers
  end
  
  def possible_subscribers
    company_contacts = company.contacts
    account_users = account.users
    account_users + company_contacts
  end
  
  def notification_email_subject
    object = commentable
    object_name = commentable.class.model_name.human.titleize # Translated
    "[Nuevo Comentario] #{object_name} ##{object.number} - #{object.subject} - #{object.company.name}"
  end
  
  def subscribers
    list = Array.new
    list << account_subscribers
    list << company_subscribers
    list.flatten
  end
  
  def subscribers_emails
    subscribers.map {|s| s.email }
  end
  
  private
  
  def notify
    return if subscribers_emails.empty?
    CommentMailer.delay.comment_notification(id)
  end
  
  def set_subscribers
    return if subscribers_ids.nil?
    self.account_users_ids = subscribers_ids[:account]
    self.company_users_ids = subscribers_ids[:company] unless private?
  end
  
end
