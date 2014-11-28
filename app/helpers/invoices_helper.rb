module InvoicesHelper
  
  def activation_requirements_message(invoice)
    fields = Array.new
    fields << "número válido" unless invoice.has_number?
    fields << "contacto" unless invoice.has_contact?
    fields << "factura en pdf" unless invoice.has_invoice_attachment?
    fields.join(", ")
  end
  
  def change_invoice_state_menu(invoice)
    case invoice.status
    when "draft"
      "Activar venta"
    when "active"
      "Recibir pago"
    end
  end
  
  def display_input_or_value_for(f, value=nil)
    return "<td style='height: 35px'><div class='value'>value</div></td>".html_safe if params[:action] == "show"
    "<td>#{f.text_field value }</td>".html_safe
  end
  
  
  def display_select_or_value_for(f, value=nil,array)
    f.select value, options_for_select(array) unless params[:action] == "show"
  end
  
  def display_invoice_status(invoice)
    status = I18n.t "invoice.#{@invoice.status}"
    status.humanize.gsub(/dte/, "DTE...")
  end
  
  def input_disabled?
    return "disabled" if params[:action] == "show"
  end
  
  def invoice_item_types_for_select()
    InvoiceItem.types.map {|ii| ii.titleize}
  end
  
  def invoice_tax_label(invoice)
    return "Afecta" if invoice.taxed?
    return "Exenta"
  end
  
  # TODO: Hacer esto unnobstrusive
  def link_to_add_invoice_item_fields(name, f, association, partial_folder, locals={})
    #debug f.object.class.reflect_on_association(association.to_sym).klass.new
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "_replaceme_") do |builder|
      render(partial_folder + "/" + association.to_s.singularize + "_fields", locals.merge!(:f => builder))
    end
    link_to_function(name, ("add_invoice_item_fields(this,\"#{association}\", \"#{escape_javascript(fields.html_safe)}\")").html_safe)
  end
  
  
  def totals_resume_invoices_row(status, total)
    status_text = I18n.t "invoice.#{status}".pluralize
    total_text = number_to_currency(total)
    checked = checkbox_status_checked?(status)
    
		"<tr class='invoices-#{status}'>
			<td class="">
				<label class='checkbox'>
              #{ check_box_tag 'search[status]', status, checked }
				       #{status_text.titleize}
				    </label>
			</td>
			<td class='total-amount'>#{total_text}</td>
		</tr>".html_safe
  end
  
  def suggested_number(invoice)
    return invoice.number if invoice.active? && !invoice.nil?
    return invoice.suggested_number
  end
  
  def number_for_invoice(invoice)
    number = current_account.e_invoice_enabled? ? invoice.suggested_number : invoice.number
    number_field_tag(:number, number, data: {"validation-number-message" => "Tiene que ser un numero"})
  end
  
  def suggested_active_date(invoice)
    return l invoice.active_date unless invoice.active_date.nil?
    return l Date.today
  end
  
  def checkbox_status_checked?(status)
    return false if params["search"].nil?
    return false if params["search"]["status"].nil?
    return params["search"]["status"] == status
  end
  
  def index_invoice_number_display(invoice)
    return "id-#{invoice.id}" if invoice.number.nil?
    "##{invoice.number}"
  end
  
  
end
