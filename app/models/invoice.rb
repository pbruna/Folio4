class Invoice < ActiveRecord::Base
  include AASM

  STATUS_NAME = %w(active draft due)
  CURRENCIES = %w(CLP UF USD)
  
  belongs_to :account
  belongs_to :company

  #Scopes
  default_scope { where(account_id: Account.current_id) }
  scope :for_account, ->(account_id) {where(:id => account_id)}
  
  # States
  aasm do
    state :draft, initial: true
    state :open
    state :due
    state :closed
  end
  
  def company_name=
    
  end
  
  def company_name
    company.name
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

end
