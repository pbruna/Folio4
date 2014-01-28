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
  
  
end
