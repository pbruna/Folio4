class InvoiceItem < ActiveRecord::Base
  # esto es para tener la columna llamada type
  self.inheritance_column = nil
  
  TYPES = %w(producto servicio)
  
  # Asociations
  belongs_to :invoice
  
  #Callbacks
  before_save :permform_calculations
  
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
