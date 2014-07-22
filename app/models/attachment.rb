class Attachment < ActiveRecord::Base
  	belongs_to :attachable, polymorphic: true
    belongs_to :author, polymorphic: true
    validates :resource, :attachment_presence => true
    
    has_attached_file :resource
    
    CATEGORIES = {
      invoice: "invoice"
    }
    
    
    def self.categories
      CATEGORIES
    end
  
end
