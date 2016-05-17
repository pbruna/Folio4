class MoneyAccount < ActiveRecord::Base

  # Define the account types like credit cards, line of credit, etc.
  ACCOUNT_TYPES = [
    { id: 1, name: 'Cuenta Corriente', credit: false },
    { id: 2, name: 'Inversiones', credit: false },
    { id: 3, name: 'Línea de Crédito', credit: true },
    { id: 4, name: 'Tarjeta de Crédito', credit: true }
  ]

  # Associations
  belongs_to :account, dependent: :destroy

  # Validations
  validates_presence_of :name, :number, :bank_name, :account_id, :type_id

  # Devuelve si la cuenta es del tipo credito, como Visa
  # Esto depende del tipo de cuenta
  def credit?
    MoneyAccount.types_as_hash[type_id.to_s][:credit]
  end

  # Return an array of MoneyAccountTypes
  def self.types
    ACCOUNT_TYPES.map do |type|
      OpenStruct.new type
    end
  end

  def self.types_as_hash
    hash = {}
    ACCOUNT_TYPES.each do |type|
      tmp = type.dup
      hash[tmp.delete(:id).to_s] = tmp
    end
    hash
  end

end
