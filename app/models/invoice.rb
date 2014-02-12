class Invoice < ActiveRecord::Base
  include AASM

  STATUS_NAME = %w(open draft closed)
  CURRENCIES = %w(CLP UF USD)
  TAX_RATE = 19
  
  # Asociatons
  belongs_to :account
  belongs_to :company
  has_many :invoice_items, :dependent => :destroy
  accepts_nested_attributes_for :invoice_items, :allow_destroy => true
  
  #Callbacks
  before_save :set_due_date
  before_validation :permform_calculations
  before_update :close_invoice_if_total_payed_match_total
  
  
  # Validations
  validates_presence_of :company_id, :subject, :number, :open_date, :due_days, :currency, :currency_convertion_rate
  validates_numericality_of :number, :due_days
  validates_numericality_of :total, :greater_than => 0
  validates_numericality_of :currency_convertion_rate, :greater_than => 0
  validates_numericality_of :net_total, :greater_than => 0
  validates_numericality_of :total_payed, :on => :update, less_than_or_equal_to: ->(invoice) { invoice.total }
  validates :number, uniqueness: {scope: [:taxed, :account_id]}
  validates :invoice_items, length: {minimum: 1, message: "Debe tener al menos un Item"}
  validate :invoice_open_for_payment

  #Scopes
  default_scope { where(account_id: Account.current_id) }
  scope :for_account, ->(account_id) {where(:id => account_id)}
  
  # States
  aasm do
    state :draft, initial: true
    state :open
    state :closed
    
    event :open! do
      transitions from: :draft, to: :open
    end
    
    event :close! do
      transitions from: :open, to: :closed, guard: :is_really_payed?
      close_date = Date.today
    end
    
  end
  
  
  def company_name=
    
  end
  
  def company_name
    return "" if company_id.nil?
    company.name
  end
  
  def is_really_payed?
    return total_payed == total
  end
  
  def status
    aasm_state
  end
  
  def self.currencies
    CURRENCIES
  end
  
  
  def suggested_number
    return 1 if read_attribute("number") == 0
    return account.invoices.last.number + 1 if number.nil?
    return number
  end

  STATUS_NAME.each do |status|
    scope status.to_sym, -> {(all)}
  end
  
  private
  def set_due_date
    self.due_date = open_date + due_days
  end
  
  def calculate_tax
    self.total = net_total
    return unless self.taxed?
    self.tax_total = (net_total * TAX_RATE/100)
    self.total = tax_total + net_total
  end
  
  def calculate_clp_from_currency
    return if currency.downcase == "clp"
    self.original_currency_total = net_total
    self.net_total = original_currency_total * currency_convertion_rate
  end
  
  def calculate_net_total_from_invoice_items
    self.net_total = invoice_items.reject(&:marked_for_destruction?).map(&:calculate_total).sum
  end
  
  # Cerrar la factura si el monto de pago calza con el total de la factura
  def close_invoice_if_total_payed_match_total
    return unless total_payed_changed?
    return unless is_really_payed?
    self.close_date = Date.today
    self.close!
  end

  # Solo se debería poder abonar si la factura esta activa
  def invoice_open_for_payment
    return if self.open?
    return if total_payed == 0
    errors.add(:total_payed, "Sólo se puede pagar cuando la venta está activa")
  end
  
  
  def permform_calculations
    calculate_net_total_from_invoice_items
    calculate_clp_from_currency
    calculate_tax
  end

end
