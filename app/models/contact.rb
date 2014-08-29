class Contact < ActiveRecord::Base
	has_many :invoices
	belongs_to :account
	belongs_to :company
  has_many :comments, as: :author
  has_many :attachments, as: :author

	validates_presence_of :name, :company_id, :email
	validates_format_of :email, :with  => Devise.email_regexp
  
  alias_method :organization, :company

  def full_name
    return email if (name.nil?)
    name
  end
  
  def organization_id
    organization.id
  end

end
