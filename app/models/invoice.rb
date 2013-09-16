class Invoice < ActiveRecord::Base

  STATUS_NAME = %w(active draft due)
  
  belongs_to :account


  #Scopes
  default_scope { where(account_id: Account.current_id) }
  scope :for_account, ->(account_id) {where(:id => account_id)}

  STATUS_NAME.each do |status|
    scope status.to_sym, -> {(all)}
  end

end
