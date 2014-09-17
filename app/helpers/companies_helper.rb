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
  
  def payment_days_message(company)
    return unless company.payment_days_median
    message = "Paga generalmente con <strong>#{company.payment_days_median} días de atraso</strong>"
    message = "Cliente siempre paga al día" if company.payment_days_median < 1
    content_tag :div, class: "pull-right totals-kpi-box-header" do 
      content_tag :h5, class: "payment-days-message" do
        message.html_safe
      end
    end
  end
  
  
end
