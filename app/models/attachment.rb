class Attachment < ActiveRecord::Base
  	belongs_to :attachable, polymorphic: true
    belongs_to :author, polymorphic: true
    belongs_to :account
    validates :resource, :attachment_presence => true
    
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
    
    def author_name
      return "Anónimo" if author.nil?
      author.name
    end
    
    def name
      read_attribute(:name) || resource_file_name
    end
    
    def download_url
      resource.url
    end
  
end
