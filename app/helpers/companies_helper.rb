module CompaniesHelper
  
  def display_company_avatar(company, size = :medium)
    content_tag(:img, nil,:src => company.avatar.url(size))
  end
  
  def company_label_customer(company)
    return unless company.has_invoices?
    content_tag(:span, "cliente", :class => "label label-customer")
  end
  
  def company_label_provider(company)
    return unless company.has_invoices?
    content_tag(:span, "proveedor", :class => "label label-provider")
  end
  
  
end
