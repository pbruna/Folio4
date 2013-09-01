module ApplicationHelper
  
  def current_account
    return if current_user.nil?
    current_user.account
  end
  
  def navbar_menu_link(title, url)
    html_class = controller_for_url(request.url) == controller_for_url(url) ? "active" : "inactive"
    content_tag(:li, (link_to title, url), :class => html_class)
  end
  
  def menu_link(title, path)
    html_class = request.path == path ? "active" : "inactive"
    content_tag(:li, (link_to title, path), :class => html_class)
  end
  
  def controller_for_url(url)
    Rails.application.routes.recognize_path(url)[:controller]
  end
  
  def get_indicator_value_for(indicador)
    indicadores = Indicadores::Chile.new
    indicadores.send(indicador)
  end
  
end
