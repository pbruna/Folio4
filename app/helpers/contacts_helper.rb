module ContactsHelper
  
  def show_attribute_contact(contact_attr, attr_icon = nil)
    return if (contact_attr.nil? || contact_attr.empty?)
    "<li>#{fa_icon attr_icon} #{contact_attr}</li>".html_safe
  end
  
end