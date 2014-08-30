class Contact < ActiveRecord::Base
	has_many :invoices
	belongs_to :account
	belongs_to :company
  has_many :comments, as: :author
  has_many :attachments, as: :author

	validates_presence_of :name, :company_id, :email
	validates_format_of :email, :with  => Devise.email_regexp
  
  alias_method :organization, :company
  
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "60x60>" }, default_url: :default_avatar_url
  
  def default_avatar_url
    identicon = Base64.strict_encode64 generate_identicon
    "data:image/png;base64,#{identicon}"
  end
  
  def generate_identicon
    if self.new_record?
      key = (0...20).map { (65 + rand(26)).chr }.join
    else
      key = self.email
    end
    RubyIdenticon.create("RubyIdenticon", key: key)
  end

  def full_name
    return email if (name.nil?)
    name
  end
  
  def organization_id
    organization.id
  end

end
