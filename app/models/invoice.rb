class Invoice < ActiveRecord::Base
  attr_accessor :new_state
  
  
  include AASM

  STATUS_NAME = %w(active draft closed)
  CURRENCIES = %w(CLP UF USD)
  TAX_RATE = 19
  
  # Asociatons
  belongs_to :account
  belongs_to :company
  has_many :invoice_items, dependent: :destroy
  has_one :reminder, as: :remindable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  belongs_to :contact
  accepts_nested_attributes_for :invoice_items, :allow_destroy => true
  accepts_nested_attributes_for :reminder, :allow_destroy => true
  accepts_nested_attributes_for :attachments, :allow_destroy => true
  
  #Callbacks
  before_validation :set_due_date_and_reminder, if: :draft?
  before_validation :permform_calculations
  before_update :close_invoice_if_total_payed_match_total
  
  
  # Validations
  validates_presence_of :company_id, :contact_id, :subject, :active_date, :due_days, :currency, :currency_convertion_rate
  validates_numericality_of :due_days
  validates_numericality_of :total, :greater_than => 0
  validates_numericality_of :currency_convertion_rate, :greater_than => 0
  validates_numericality_of :net_total, :greater_than => 0
  validates_numericality_of :total_payed, :on => :update, less_than_or_equal_to: ->(invoice) { invoice.total }
  validates :invoice_items, length: {minimum: 1, message: "Debe tener al menos un Item"}
  validate :invoice_ready_for_payment
  validates_presence_of :number, unless: :draft?
  validates_numericality_of :number, unless: :draft?
  validates :number, uniqueness: {scope: [:taxed, :account_id]}, unless: :draft?

  #Scopes
  #default_scope { where(account_id: Account.current_id) }
  scope :for_account, ->(account_id) {where(:id => account_id)}
  scope :actives, ->() {where(aasm_state: "active")}
  scope :not_draft, ->() {where.not(aasm_state: "draft")}
  scope :taxed, ->() {where(taxed: true)}
  scope :not_taxed, ->() {where(taxed: false)}
  
  STATUS_NAME.each do |status|
    scope status.to_sym, ->() {where(aasm_state: status)}
  end
  
  # States
  aasm :create_scopes => false, :whiny_transitions => false do
    state :draft, initial: true
    state :active
    state :closed
    
    event :active, after: Proc.new { run_activation_jobs } do 
      transitions from: :draft, to: :active, guard: :ready_for_activation?
    end
    
    event :close do
      transitions from: :active, to: :closed, guard: :is_really_payed?
      close_date = Date.today
    end
    
  end
  
  def run_activation_jobs
    schedule_reminder
    activation_notification_email
  end
  
  def schedule_reminder
    reminder = update_reminder
    reminder.schedule!
  end
  
  def activation_notification_email
    InvoiceMailer.delay.activation_notification(self)
  end
  
  def change_status(params)
    new_state = params.delete :new_state
    return false unless STATUS_NAME.include? new_state.downcase
    unless send("may_#{new_state}?")
      update_attributes(params)
    end
    self.send(new_state)
    save
  end
  
  def company_name=
    
  end
  
  def company_name
    return "" if company_id.nil?
    company.name
  end

  def company_contacts
    return [] unless company_has_contact?
    company.contacts
  end

  def company_has_contact?
    return false if company.nil?
    company.has_contacts?
  end
  
  def has_valid_number?
    account.check_invoice_number_availability(number,taxed)
  end

  def notification_date
    return reminder.notification_date unless reminder.notification_date.nil?
    Date.today + 30 
  end

  def has_contact?
    !contact.nil? && (contact.company_id == company_id)
  end
  
  def has_number?
    !number.nil?
  end
  
  def has_invoice_attachment?
    attachments.where(category: "invoice").any?
  end
  
  def dte_attachment
    attachments.where(category: "invoice").first
  end
  
  def dte_attachment_url
    dte_attachment.resource.url
  end

  def contact_name
    return "" unless has_contact?
    contact.name
  end
  
  def is_really_payed?
    return total_payed == total
  end
  
  def invoices_for_account
    begin
      account.invoices
    rescue Exception => e
      raise "The invoice must belong to an account"
    end
  end
  
  def last_used_number
    last_active_invoice = invoices_for_account.actives.last
    return 0 if last_active_invoice.nil?
    last_active_invoice.number
  end
  
  
  def status
    aasm_state
  end
  
  def self.currencies
    CURRENCIES
  end
    
  def suggested_number
    return 1 unless invoices_for_account.any?
    return last_used_number + 1
  end
  
  def update_invoice(params)
      update_attributes(params)
  end
  
  def default_reminder_subject
    number_string = number.to_s || "NA"
    "Recordatorio vencimiento Factura #{self.number}"
  end
  
  # def reminder
  #   reminders.first
  # end
  
  def set_due_date_and_reminder
    self.due_date = active_date + due_days
    self.update_reminder
  end
  
  def update_reminder
    self.reminder.subject = default_reminder_subject
    self.reminder.notification_date = nil 
    self.reminder.due_date = due_date
    self.set_reminder_contacts
    reminder
  end
  
  def set_reminder_contacts
    reminder.account_users_ids = account_users_ids
    reminder.company_users_ids = company_users_ids
  end
  
  def account_users_ids
    account.users.map {|u| u.id}
  end
  
  def company_users_ids
    return [] if contact.nil?
    [contact.id]
  end
  
  def calculate_tax
    self.total = net_total
    return unless self.taxed?
    self.tax_total = (net_total * TAX_RATE/100)
    self.total = tax_total + net_total
  end
  
  def calculate_net_total_from_currency_total
    self.net_total = original_currency_total * currency_convertion_rate
  end
  
  def calculate_original_currency_total_from_invoice_items
    items_sum = invoice_items.reject(&:marked_for_destruction?).map(&:calculate_total).sum
    self.original_currency_total = items_sum 
  end
  
  # Cerrar la factura si el monto de pago calza con el total de la factura
  def close_invoice_if_total_payed_match_total
    return unless total_payed_changed?
    return unless is_really_payed?
    self.close_date = Date.today
    self.close
  end

  # Solo se debería poder abonar si la factura esta activa
  def invoice_ready_for_payment
    return if self.active?
    return if total_payed == 0
    errors.add(:total_payed, "Sólo se puede pagar cuando la venta está activa")
  end
  
  
  def permform_calculations
    set_currency_convertion_rate(currency.downcase)
    calculate_original_currency_total_from_invoice_items
    calculate_net_total_from_currency_total
    calculate_tax
  end
  
  def ready_for_activation?
    return (has_contact? && has_number? && has_invoice_attachment? && valid?)
  end
  
  def set_currency_convertion_rate(indicador)
    indicador = "dolar" if indicador == "usd"
    self.currency_convertion_rate = 1
    indicadores = Indicadores::Chile.new
    begin
      self.currency_convertion_rate = indicadores.send(indicador)
    rescue Exception => e
    end
    
  end

end
