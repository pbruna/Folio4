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
    
    def self.new_from_dte(hash={})
      return if hash.nil?
      attachment = new()
      attachment.name = hash[:name]
      attachment.file_from_base64 hash[:file]
      attachment.author_id = attachment.attachable.account.owner_id
      attachment.account_id = attachment.attachable.account_id
      attachment.author_type = "User"
      attachment
    end
    
    def file_from_base64(base64_string)
      StringIO.open(Base64.strict_decode64(base64_string)) do |data|
          data.class.class_eval { attr_accessor :original_filename, :content_type }
          data.original_filename = "temp#{DateTime.now.to_i}.pdf"
          data.content_type = "application/pdf" #TODO: get content type from file
          self.resource = data
      end
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
      return resource.url unless in_s3?
      resource.s3_object.url_for(
        :read, :secure => true, :expires => 300.minutes,
        response_content_disposition: "attachment; filename='#{download_name}'"
        ).to_s
    end
    
    def in_s3?
      !resource.url.match(/s3.amazonaws.com/).nil?
    end
    
    def download_name
      if name.nil?
        return resource_file_name if original_file_name.nil?
        original_file_name
      else
        name
      end
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
