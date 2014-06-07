class Company < ActiveRecord::Base
  belongs_to :account
  has_many :invoices
  has_many :contacts
  
  scope :for_account, -> {where(account_id: Account.current_id)}
  
  has_attached_file :avatar, :styles => { :large => "300x300>", :medium => "150x150>", :thumb => "60x60>" }, default_url: :default_avatar_url
  validates_presence_of :rut, :name, :address, :province, :city
  validates_uniqueness_of :rut, :scope => [:account_id]
  validates_with RutValidator
  
  def default_avatar_url
    identicon = generate_identicon
    "data:image/png;base64,#{identicon}"
  end
  
  def generate_identicon
    key = name.nil? ? random_string : name + "1234567891011121314"
    blob = RubyIdenticon.create("RubyIdenticon", key: key)
    Base64.strict_encode64 blob
  end
  
  def has_invoices?
    invoices.any?
  end

  def has_contacts?
    contacts.any?
  end
  
  def self.in_alphabetycal_order(company_name_like)
    return order("name") if company_name_like.nil?
    where('name LIKE ?', "%#{company_name_like}%")
  end

  
  def invoices_due_total
    20090203
  end
  
  def sales_total
    209093293
  end
  
  def payment_grade
    4.5
  end
  
  private
  def random_string
    (0...17).map{ ('a'..'z').to_a[rand(26)] }.join
  end
  
end
