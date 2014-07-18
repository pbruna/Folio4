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
    begin
      indicadores.send(indicador)
    rescue Exception => e
      0
    end
  end
  
  def round_number_and_delimiter(number)
    number_with_delimiter(number.ceil)
  end
  
  def search_add_record_link(path, title)
    	link_to content_tag(:i, nil, :class => "icon-plus icon-white").html_safe+" #{title}", path, :class => "btn btn-success"
  end

  def render_modal(options=Hash.new(""))
    render partial: "shared/modal", locals: {options: options}
  end

  def render_modal_form(options=Hash.new(""))
    render partial: "shared/modal_form", locals: {options: options}
  end
  
  def textarea_display(text)
      text.gsub(/\n/, "<br/>").html_safe
  end
  
end
