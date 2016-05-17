class Reconcilation < ActiveRecord::Base
  belongs_to :money_account
  belongs_to :user
  
  validates_presence_of :debit, :debt, :currency, :user_id, :money_account_id
  
end
