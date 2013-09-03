class Account < ActiveRecord::Base
  USERS_COUNT_MIN = 1
  
  has_many :users, :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  has_many :expenses, :dependent => :destroy
  has_many :audits, :dependent => :destroy
  accepts_nested_attributes_for :users, :allow_destroy => true
  
  validates_uniqueness_of :subdomain, :rut, :name
  validates_presence_of :subdomain, :name
  validate :check_users_number # The account must have at least one user
  
  after_save :initialize_account
  before_validation :clear_subdomain

  def self.subdomain_available?(subdomain)
    exists?(:subdomain => subdomain).nil? ? true : false
  end
  
  def owner
    User.find(owner_id)
  end
  
  def contact_info_complete?
    attributes.detect {|k,v| v.blank? }.nil?
  end
  
  def owner_name
    return owner.email if owner.full_name.nil?
    owner.full_name
  end
  
  def trial?
    plan_id == Plan.trial.id
  end
  
  def has_data?
    invoices.any? || expenses.any?
  end
  
  
  Invoice::STATUS_NAME.each do |status|
    define_method "#{status}_invoices" do
      self.invoices.send(status)
    end
  end
  
  
  private
  
  def users_count_valid?
    users.length >= USERS_COUNT_MIN    
  end
  
  def check_users_number
    unless users_count_valid?
      errors.add(:base, :users_too_short, :count => USERS_COUNT_MIN)
    end
  end
  
  def initialize_account
    set_owner
    set_trial_plan
  end
  
  def set_owner
    update_column("owner_id", self.users.last.id) if owner_id.nil?
  end
  
  def set_trial_plan
    update_column("plan_id", Plan.trial.id) if plan_id.nil?
  end
  
  def clear_subdomain
    subdomain.split(/\./).join("")
  end
  
end
