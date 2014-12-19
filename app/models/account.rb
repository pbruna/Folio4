class Account < ActiveRecord::Base
  USERS_COUNT_MIN = 1

  has_many :users, :dependent => :destroy
  has_many :invoices, :dependent => :destroy
  has_many :expenses, :dependent => :destroy
  has_many :audits, :dependent => :destroy
  has_many :companies, :dependent => :destroy
  has_many :contacts, through: :companies
  has_many :attachments, :dependent => :destroy
  has_many :dtes, :dependent => :destroy
  accepts_nested_attributes_for :users, :allow_destroy => true

  validates_uniqueness_of :subdomain
  validates_presence_of :subdomain, :name
  validates_format_of :subdomain, :with => /^((?!^(www|folio|app|dev)).)*$/i, :message => "No puedes usar ese nombre", multiline: true
  validate :check_users_number # The account must have at least one user
  validates_presence_of :industry, :if => :e_invoice_enabled?
  validates_presence_of :industry_code, :if => :e_invoice_enabled?
  #validates_presence_of :e_invoice_resolution_date, :if => :e_invoice_enabled?

  after_save :initialize_account
  before_validation :clear_subdomain

  def self.per_page
    
  end

  def self.subdomain_available?(subdomain)
    return false if "/^((?!^(www|folio|app|dev)).)*$/i".match(subdomain)
    !exists?(:subdomain => subdomain.downcase)
  end
  
  def check_invoice_number_availability(number, taxed)
    value = number.to_i
    return !invoices.not_draft.taxed.where(number: value).any? if taxed.to_s == "true"
    return !invoices.not_draft.not_taxed.where(number: value).any?
  end
  
  def invoice_last_used_number(taxed = false)
    unless invoices.not_draft.any?
      return (dte_invoice_start_number - 1) if e_invoice_enabled? && taxed
      return (dte_invoice_untaxed_start_number - 1) if e_invoice_enabled? && !taxed
      return 0
    end
    #invoices.not_draft.select(:number).order("number desc").limit(1).first.number
    return invoices.taxed.select(:number).order("number desc").limit(1).first.number if taxed
    return invoices.not_taxed.select(:number).order("number desc").limit(1).first.number unless taxed
  end
  
  def last_used_dte_nc_number
    return (dte_nc_start_number - 1) unless has_dte_nc?
    dtes.dte_ncs.last.folio
  end
  
  def has_dte_nc?
    dtes.dte_ncs.any?
  end

  def owner
    User.find(owner_id)
  end

  def contact_info_complete?
    attributes.detect {|k,v| v.blank? unless k == "e_invoice_enabled" }.nil?
  end
  
  def companies_in_alphabetycal_order(company_name_like)
    companies.in_alphabetycal_order(company_name_like)
  end

  def owner_name
    owner.full_name
  end

  def trial?
    plan_id == Plan.trial.id
  end

  def has_data?
    invoices.any? || expenses.any?
  end
  
  def has_invoices?
    invoices.any?
  end
  
  def invoices_search(params)
    invoices.search(params)
  end


  Invoice::STATUS_NAME.each do |status|
    define_method "#{status}_invoices" do
      self.invoices.send(status)
    end
  end


  def self.current_id=(id)
    Thread.current[:tenant_id] = id
  end

  def self.current_id
    Thread.current[:tenant_id]
  end
  
  # Invoice totals
  def total_due
    invoices.total_due
  end
  
  def total_active
    invoices.total_active
  end
  
  def total_closed
    invoices.total_closed
  end
  
  def total_draft
    invoices.total_draft
  end
  
  def users_emails_array
    users.map {|u| u.email}
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
