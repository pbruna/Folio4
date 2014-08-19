class Invoice < ActiveRecord::Base
  attr_accessor :new_state
  
  
  include AASM

  STATUS_NAME = %w(active draft closed)
  CURRENCIES = %w(CLP UF USD)
  TAX_RATE = 19
  self.per_page = 10
  
  # Asociatons
  belongs_to :account
  belongs_to :company
  has_many :invoice_items, dependent: :destroy
  has_one :reminder, as: :remindable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :contact
  accepts_nested_attributes_for :invoice_items, :allow_destroy => true
  accepts_nested_attributes_for :reminder, :allow_destroy => true
  accepts_nested_attributes_for :attachments, :allow_destroy => true
  
  #Callbacks
  before_validation :set_due_date_and_reminder, if: :draft?
  before_validation :permform_calculations
  before_update :close_invoice_if_total_payed_match_total
  
  # Solo borramos si esta en Draft
  before_destroy {|record| return false unless record.draft? }
  
  
  # Validations
  validates_presence_of :company_id, :contact_id, :subject, :active_date, :due_days, :currency, :currency_convertion_rate
  validates_numericality_of :due_days
  validates_numericality_of :total, :greater_than => 0
  validates_numericality_of :currency_convertion_rate, :greater_than => 0
  validates_numericality_of :net_total, :greater_than => 0
  validates_numericality_of :total_payed, :on => :update, less_than_or_equal_to: ->(invoice) { invoice.total }
  validates :invoice_items, length: {minimum: 1, message: "Debe tener al menos un Item"}
  #validate :invoice_ready_for_payment
  validates_presence_of :number, unless: :draft?
  validates_numericality_of :number, unless: :draft?
  validates :number, uniqueness: {scope: [:taxed, :account_id]}, unless: :draft?

  #Scopes
  #default_scope { where(account_id: Account.current_id) }
  scope :for_account, ->(account_id) {where(:id => account_id)}
  scope :active, ->() {where("aasm_state = ? and due_date >= ?", "active", Date.today )}
  scope :due, ->() {where("aasm_state = ? and due_date < ?", "active", Date.today )}
  scope :draft, ->() {where(aasm_state: "draft")}
  scope :not_draft, ->() {where.not(aasm_state: "draft")}
  scope :closed, ->() {where(aasm_state: "closed")}
  scope :cancelled, ->() {where(aasm_state: "cancelled")}
  scope :taxed, ->() {where(taxed: true)}
  scope :not_taxed, ->() {where(taxed: false)}
  scope :all_invoices, ->() {all}
  
  # States
  aasm :create_scopes => false, :whiny_transitions => false do
    state :draft, initial: true
    state :active
    state :closed
    state :cancelled
    
    event :active, after: Proc.new { run_activation_jobs } do 
      transitions from: :draft, to: :active, guard: :ready_for_activation?
    end
    
    event :cancel do
      transitions from: :active, to: :cancelled
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
  
  def clone!
    source_invoice = self.reset_for_cloning
    new_invoice = source_invoice.dup
    new_invoice.invoice_items << source_invoice.clone_items
    new_invoice
  end
  
  def clone_items
    invoice_items_tmp = Array.new
    return false if invoice_items.size < 0
    invoice_items.each_with_index do |line, index|
      line.invoice_id = nil
      invoice_items_tmp << line.dup
    end
    invoice_items_tmp
  end
  
  def reset_for_cloning
    self.active_date = Date.today
    self.aasm_state = "draft"
    self.total_payed = 0
    self.number = nil
    self
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
    return reminder.notification_date unless (reminder.nil? || reminder.notification_date.nil?)
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
  
  def has_debt?
    total_payed.to_i > 0 && total_payed.to_i < total.to_i
  end
  
  def debt
    total - total_payed
  end

  def contact_name
    return "" unless has_contact?
    contact.name
  end
  
  def is_really_payed?
    return total_payed.to_i == total.to_i
  end
  
  def invoices_for_account
    begin
      account.invoices
    rescue Exception => e
      raise "The invoice must belong to an account"
    end
  end
  
  def last_used_number
    last_active_invoice = invoices_for_account.active.last
    return 0 if last_active_invoice.nil?
    last_active_invoice.number
  end
  
  def may_edit?
    draft? || active?
  end
  
  
  def status
    return "draft" if new_record?
    return "due" if is_due?
    aasm_state
  end
  
  # Esta vencida si se pasó la fecha y está activa
  def is_due?
    due_date < Date.today && active?
  end
  
  def late_days
    (Date.today - due_date).to_i
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
  
  def pay(amount)
    return false unless active?
    self.total_payed = amount.to_s.gsub(/[^\d]/,"").to_i + total_payed.to_i
    self.save
  end
  
  def set_due_date_and_reminder
    date = active_date || Date.today
    self.due_date = date + due_days
    self.update_reminder
  end
  
  def update_reminder
    self.reminder ||= build_reminder(due_date: i.due_date)
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
  
  # Búsqueda simple
  def self.search(params)
    Rails.logger.debug("AQUI #{params}")
    params = Hash.new(nil) if params.nil?
    query_items = params["query_items"].nil? ? {} : params["query_items"].delete_if {|k,v| v.empty?}
    start_date = Date.parse(query_items.delete("start_date")) unless query_items["start_date"].nil?
    end_date = Date.parse(query_items.delete("end_date")) unless query_items["end_date"].nil?
    status = params["status"].nil? ? "all_invoices" : params["status"]
    sorted_by = params["sorted_by"].nil? ? "active_date" : params["sorted_by"]
    sorted_direction = params["sorted_direction"].nil? ? "DESC" : params["sorted_direction"]
    results = send(status).where(query_items)
    if start_date && end_date.nil?
      results = results.where("active_date >= ?", start_date)
    elsif start_date.nil? && end_date
      results = results.where("active_date <= ?", end_date)
    elsif start_date && end_date
      results = results.where(active_date: start_date..end_date)
    end
    results.order("#{sorted_by} #{sorted_direction}").includes(:company)
  end
  
  # Return the sum of the totals
  def self.total_due
    due.to_a.sum(&:total).to_i
  end
  
  def self.total_active
    active.to_a.sum(&:total).to_i
  end
  
  def self.total_closed
    closed.to_a.sum(&:total).to_i
  end
  
  def self.total_draft
    draft.to_a.sum(&:total).to_i
  end
  
  
  def permform_calculations
    set_currency_convertion_rate(currency.downcase)
    calculate_original_currency_total_from_invoice_items
    calculate_net_total_from_currency_total
    calculate_tax
  end
  
  def ready_for_activation?
    return (has_contact? && has_valid_number? && valid?)
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
