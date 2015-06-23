class Company < ActiveRecord::Base
  belongs_to :account
  has_many :invoices
  has_many :contacts
  
  scope :for_account, -> {where(account_id: Account.current_id)}
  
  has_attached_file :avatar, :styles => { :large => "300x300>", :medium => "150x150>", :thumb => "60x60>" }, default_url: :default_avatar_url
  validates_presence_of :rut, :name, :address, :province, :city, :account_id, :industry
  validates_uniqueness_of :rut, :scope => [:account_id]
  validates_with RutValidator
  
  before_destroy :check_if_empty
  
  def empty?
    !invoices.any?
  end
  
  def contacts_in_alphabetycal_order(contact_name_like)
    return contacts.order("name") if contact_name_like.nil?
    contacts.where('name LIKE ?', "%#{contact_name_like}%")
  end
  
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

  def invoices_search(params)
    invoices.search(params)
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
  
  def payment_days_median
    return nil if empty?
    return nil if invoices.closed.empty?
    invoices.closed.map {|i| i.payment_days}.median.round
  end
  
  # Esto es para buscar por rut o id en 
  # invoices_controller
  # http://masev.folio4.dev/companies/12454782-2/invoices.json
  def self.find_by_id_or_rut(value)
    if value.match(/-/)
      result = where(rut: format_rut(value)).first
      fail ActiveRecord::RecordNotFound if result.nil?
      result
    else
      find(value)
    end
  end
  
  def self.format_rut(raw_rut)
    rut = raw_rut.to_s.delete '.-'
    if rut.nil? || rut.empty?
      return rut
    end
    rut_end = rut[rut.length - 1, rut.length]
    rut_init_temp = rut[0, rut.length - 1]
    rut_init = ''
    while rut_init_temp.length > 3 do
      rut_init = '.' + rut_init_temp[rut_init_temp.length - 3, rut_init_temp.length] + rut_init
      rut_init_temp = rut_init_temp[0, rut_init_temp.length - 3]
    end
    rut = rut_init_temp+rut_init+'-'+rut_end
    rut.upcase
  end    
    
  def total_due
    invoices.due.to_a.sum(&:total).to_i
  end
  
  def total_active
    invoices.active.to_a.sum(&:total).to_i
  end
  
  def total_closed
    invoices.closed.to_a.sum(&:total).to_i
  end
  
  def total_draft
    invoices.draft.to_a.sum(&:total).to_i
  end
  
  private
  def random_string
    (0...17).map{ ('a'..'z').to_a[rand(26)] }.join
  end
  
  def check_if_empty
    empty?
  end  
  
end
