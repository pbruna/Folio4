module ApplicationHelper

  def link_to_add_fields(name, f, association, partial_folder, locals={})
    #debug f.object.class.reflect_on_association(association.to_sym).klass.new
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "_replaceme_") do |builder|
      render(partial_folder + "/" + association.to_s.singularize + "_fields", locals.merge!(:f => builder))
    end
    link_to_function(name, ("add_fields(this,\"#{association}\", \"#{escape_javascript(fields.html_safe)}\")").html_safe)
  end
  
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
  
  def search_add_record_link(path, title)
    	link_to content_tag(:i, nil, :class => "icon-plus icon-white").html_safe+" #{title}", path, :class => "btn btn-success"
  end
  
end
