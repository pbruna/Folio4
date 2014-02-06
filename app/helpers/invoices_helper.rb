module InvoicesHelper
  
  def totals_resume_invoices_row(status, total)
    status_text = I18n.t "invoice.#{status}".pluralize
    total_text = number_to_currency(total)
    
		"<tr class='invoices-#{status}'>
			<td class="">
				<label class='checkbox'>
				      <input type='checkbox' value='#{status}' name='invoice_status'> #{status_text.titleize}
				    </label>
			</td>
			<td class='total-amount'' style='text-align: right; vertical-align: top;'>#{total_text}</td>
		</tr>".html_safe
  end
  
  
  def display_input_or_value_for(f, value=nil)
    return "<td style='height: 35px'><div class='value'>value</div></td>".html_safe if params[:action] == "show"
    "<td>#{f.text_field value }</td>".html_safe
  end
  
  
  def display_select_or_value_for(f, value=nil,array)
    f.select value, options_for_select(array) unless params[:action] == "show"
  end
  
  def input_disabled?
    return "disabled" if params[:action] == "show"
  end
  
end
