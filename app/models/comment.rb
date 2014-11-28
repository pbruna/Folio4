require "base64"

class Comment < ActiveRecord::Base
  attr_accessor :subscribers_ids
  
  belongs_to :commentable, polymorphic: true
  belongs_to :author, polymorphic: true
  has_many :attachments, as: :attachable, dependent: :destroy
  serialize :account_users_ids
  serialize :company_users_ids
  
  after_create :notify
  before_validation :complete_attachment_fields
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
  
  def has_attachments?
    attachments.any?
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
    commentable.last_comment
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
  
  def self.new_from_email(email)
    return false if email.nil? # Si no hay correo no hacemos nada
    comment_metadata = metadata_from_email_to_field(email)
    comment_author = comment_author_from_email(email, comment_metadata[:account_id])
    comment_metadata.delete(:account_id) # El comment no tiene este campo
    # Si no hay author no hacemos nada, puede que no haya
    # porque no se encontró una cuenta valida
    return false unless comment_author
    # Tenemos que crear el comentario desde el objeto (Factura por ahora) 
    object = comment_metadata[:commentable_type].constantize.find(comment_metadata[:commentable_id])
    comment = object.comments.new comment_metadata.merge comment_author
    comment.message = email.body.html_safe
    comment.from_email = true
    if email.attachments.any?
      email.attachments.each do |attachment|
        comment.attachments.new(resource: attachment)
      end
    end
    comment
  end
  
  def subscribers
    list = Array.new
    list << account_subscribers
    list << company_subscribers unless private?
    list.flatten
  end
  
  def subscribers_emails
    subscribers.map {|s| s.email }
  end
  
  def self.new_from_system(hash={})
    return false if hash.nil?
    comment = new(hash)
    comment.author_id = comment.commentable.account.owner_id
    comment.author_type = "User"
    comment
  end
  
  private
  
  def self.metadata_from_email_to_field(email)
    ary = email.to.first[:token].split(/-/)
    ary[0] = ary[0].titleize
    ary[2] = decode_account_id(ary[2])
    keys = [:commentable_type, :commentable_id, :account_id]
    comment_metadata = Hash.new
    ary.each_with_index {|el,index| comment_metadata[keys[index]] = el }
    comment_metadata
  end
  
  def self.comment_author_from_email(email, account_id)
    account = Account.find(account_id)
    return false if account.nil?
    author = Hash.new()
    user = account.users.find_by(email: email.from[:email])
    if user
      author[:author_id] = user.id
      author[:author_type] = user.class.to_s
      return author
    end
    contact = account.contacts.find_by(email: email.from[:email])
    if contact
      author[:author_id] = contact.id
      author[:author_type] = contact.class.to_s
      return author
    end
    return false
  end
  
  def self.decode_account_id(b64_string)
    Base64.strict_decode64(b64_string).to_i
  end
  
  def notify
    return if subscribers_emails.empty?
    CommentMailer.delay.comment_notification(id)
  end
  
  def set_subscribers
    self.subscribers_ids = set_subscribers_from_email if from_email?
    return if subscribers_ids.nil?
    self.account_users_ids = subscribers_ids[:account]
    self.company_users_ids = subscribers_ids[:company] unless private?
  end
  
  def set_subscribers_from_email
    subscribers_ids = Hash.new
    subscribers_ids[:account] = last_comment.account_users_ids
    subscribers_ids[:company] = last_comment.company_users_ids
    subscribers_ids
  end
  
  def complete_attachment_fields
    return unless attachments.any?
    attachments.each do |att|
      att.author_id ||= author_id
      att.author_type ||= author_type
      att.account_id ||= account.id
    end
  end
  
end
