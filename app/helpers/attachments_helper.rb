module AttachmentsHelper
  
  def display_attachment_name(attachment)
    attachment.name.empty? ? attachment.original_file_name : attachment.name.titleize
  end

end
