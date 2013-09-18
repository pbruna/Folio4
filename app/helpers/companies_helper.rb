module CompaniesHelper
  
  def display_company_avatar(company, size = :thumb)
    content_tag(:img, nil,:src => company.avatar.url(size))
  end
  
  
end
