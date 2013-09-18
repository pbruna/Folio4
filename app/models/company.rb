class Company < ActiveRecord::Base
  belongs_to :account
  #default_scope { where(account_id: Account.current_id) }
  
  has_attached_file :avatar, :styles => { :large => "300x300>", :medium => "150x150>", :thumb => "60x60>" }, default_url: :default_avatar_url
  validates_presence_of :rut, :name, :address, :province, :city
  validates_uniqueness_of :rut, :scope => [:account_id]
  #validates_with RutValidator
  
  def default_avatar_url
    identicon = generate_identicon
    "data:image/png;base64,#{identicon}"
  end
  
  def generate_identicon
    key = name.nil? ? random_string : name + "1234567891011121314"
    blob = RubyIdenticon.create("RubyIdenticon", key: key)
    Base64.strict_encode64 blob
  end
  
  private
  def random_string
    (0...17).map{ ('a'..'z').to_a[rand(26)] }.join
  end
  
end
