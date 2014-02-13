class InvoiceItem < ActiveRecord::Base
  # esto es para tener la columna llamada type
  self.inheritance_column = nil
  
  TYPES = %w(producto servicio)
  
  # Asociations
  belongs_to :invoice
  delegate :account, :to => :invoice
  
  #Callbacks
  before_validation :permform_calculations
  
  # Validations
  validates_presence_of :price, :quantity, :total
  validates_numericality_of :price, greater_than: 0
  validates_numericality_of :total, greater_than: 0
  validates_numericality_of :quantity, greater_than: 0
  
  
  def self.types
    TYPES
  end
  
  def calculate_total
    quantity * price
  end
  
  private
  
  def permform_calculations
    self.total = calculate_total
  end
  
end
