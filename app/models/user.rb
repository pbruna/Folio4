class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, #:registerable,
    :recoverable, :rememberable, :trackable, request_keys: [:subdomain]

  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true, :if => :email_changed?, :scope => :account_id
  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?
  validates_presence_of   :password, :on=>:create
  validates_confirmation_of   :password, :on=>:create
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  belongs_to :account
  has_many :audits, :dependent => :destroy
  has_many :comments, as: :author
  has_many :attachments, as: :author
  
  before_destroy :check_owner
  before_create  :active_user

  alias_method :organization, :account
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "60x60>" }, default_url: :default_avatar_url
  
  #default_scope { where(account_id: Account.current_id) }
  
  def account_owner
    account.owner
  end
  
  def active_for_authentication?
    active?
  end
  
  def inactive_message
    "El dueño de la cuenta ha bloqueado al usuario"
  end
  
  def deactivate!
    return false if owner?
    self.active = false
    save
  end
  
  def owner?
    id == account.owner_id
  end
  
  def organization_id
    organization.id
  end
  
  def account_subdomain
    account.subdomain
  end
  
  def full_name
    return email if (name.nil?)
    "#{name} #{last_name}"
  end
  
  def default_avatar_url
    identicon = Base64.strict_encode64 generate_identicon
    "data:image/png;base64,#{identicon}"
  end
  
  def generate_identicon
    if self.new_record?
      key = (0...20).map { (65 + rand(26)).chr }.join
    else
      key = self.encrypted_password
    end
    RubyIdenticon.create("RubyIdenticon", key: key)
  end
  
  def identicon_file
    data = StringIO.new(generate_identicon)
    data.original_filename = "#{full_name.downcase.gsub(/\s+/,"")}-avatar.png"
    data.content_type = "image/png"
    data
  end
  
  def self.new_from_owner(account_id, user_params)
    @user = User.new(user_params)
    @user.account_id = account_id
    token = @user.new_reset_password_token
    [@user, token]
  end

  def self.find_for_authentication(warden_conditions)
    if account = Account.where(:subdomain => warden_conditions[:subdomain]).first
      account.users.find_by_email(warden_conditions[:email])
    end
  end
  
  def new_reset_password_token
    raw, enc = Devise.token_generator.generate(User, :reset_password_token)
    self.reset_password_token = enc
    self.reset_password_sent_at = Time.now.utc
    raw
  end

  # Setup accessible (or protected) attributes for your model
  private
  def check_owner
    return unless self.owner?
    errors.add(:base, :user_is_owner)
    false
  end
  
  def active_user
    self.avatar = set_avatar
    self.active = true
  end
  
  def set_avatar
    return identicon_file if avatar.nil?
    return identicon_file if (/^data:image\/png;base64,/).match(avatar.url)
    avatar
  end

end


class StringIO
  attr_accessor :original_filename, :content_type
end