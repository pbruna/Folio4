class Invoice < ActiveRecord::Base

  STATUS_NAME = %w(active draft due)
  
  belongs_to :account


  #Scopes
  scope :for_account, ->(account_id) {where(:id => account_id)}

  STATUS_NAME.each do |status|
    scope status.to_sym, -> {(all)}
  end

end
