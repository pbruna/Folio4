class Attachment < ActiveRecord::Base
  	belongs_to :attachable, polymorphic: true
    belongs_to :author, polymorphic: true
    belongs_to :account
    validates :resource, :attachment_presence => true
    validates_presence_of :author_id, :author_type, :account_id
    
    before_save :randomize_file_name
    
    has_attached_file :resource
    
    CATEGORIES = {
      invoice: "invoice"
    }
    
    
    def self.categories
      CATEGORIES
    end
    
    def self.reverse_date
      order('created_at DESC')
    end
    
    def self.new_from_system(hash={})
      return if hash.nil?
      attachment = new()
      attachment.file_from_url hash[:url]
      attachment.name = hash[:name]
      attachment.author_id = attachment.attachable.account.owner_id
      attachment.account_id = attachment.attachable.account_id
      attachment.author_type = "User"
      attachment
    end
    
    def file_from_url(url)
      self.resource = URI.parse(url)
    end
    
    def author_name
      return "Anónimo" if author.nil?
      author.name
    end
    
    # def name
    #   read_attribute(:name) || resource_file_name
    # end
    
    def original_file_name
      read_attribute(:original_file_name) || name
    end
    
    def download_url
      resource.url
    end
    
    private
    def randomize_file_name
      return if resource_file_name.nil?
      return unless resource_file_name_changed?
      extension = File.extname(resource_file_name).downcase
      self.original_file_name = resource_file_name
      self.resource.instance_write(:file_name, "#{SecureRandom.hex(16)}#{extension}")
    end
  
end
