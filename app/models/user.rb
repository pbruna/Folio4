class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, request_keys: [:subdomain]

  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true, :if => :email_changed?, :scope => :account_id
  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?
  validates_presence_of   :password, :on=>:create
  validates_confirmation_of   :password, :on=>:create
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true

  belongs_to :account
  
  before_destroy :check_owner
  
  def owner?
    id == account.id
  end
  
  def account_subdomain
    account.subdomain
  end

  def self.find_for_authentication(warden_conditions)
    if account = Account.where(:subdomain => warden_conditions[:subdomain]).first
      account.users.find_by_email(warden_conditions[:email])
    end
  end

  # Setup accessible (or protected) attributes for your model
  private
  def check_owner
    return unless self.owner?
    errors.add(:base, :user_is_owner)
    false
  end

end
