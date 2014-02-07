class InvoiceItem < ActiveRecord::Base
  # esto es para tener la columna llamada type
  self.inheritance_column = nil
  
  TYPES = %w(producto servicio)
  
  belongs_to :invoice
  
  def self.types
    TYPES
  end
  
end
