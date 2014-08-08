require "base64"

class Comment < ActiveRecord::Base
  attr_accessor :notify_account_users
  belongs_to :commentable, polymorphic: true
  belongs_to :author, polymorphic: true
  
  after_create :notify
  
  validates_presence_of :message, :author_type, :author_id, :commentable_id, :commentable_type
  
  
  def author_name
    return "" if author.name.empty?
    author.name
  end
  
  def contacts_emails
    account_emails
  end
  
  # Generar reply
  # object_name-object_id-account_id_hash@folio.cl
  # invoice-343-363jdj739@folio.cl
  
  def email_reply_to
    # lo que va despues del arroba
    host = ActionMailer::Base.default_url_options[:host]
    "#{object_name}-#{object_id}-#{encoded_account_id}@#{host}"
  end
  
  def object_name
    commentable.class.to_s.downcase
  end
  
  def object_id
    commentable.id
  end
  
  def account_id
    commentable.account_id
  end
  
  def account_emails
    commentable.account.users_emails_array
  end
  
  def encoded_account_id
    Base64.strict_encode64(account_id.to_s)
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
