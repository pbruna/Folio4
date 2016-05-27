json.array! @invoices do |invoice|
  json.number invoice.number
  dte = invoice.attachments.where('name LIKE ? or name LIKE ?', '%factura%', '%nota%').last
  dte_link = dte ? dte.download_url : ''
  json.link dte_link
  json.date invoice.active_date
  json.total invoice.total.to_i
  json.status_name invoice.status
  case invoice.status
  when 'active'
    json.status 0
  when 'closed'
    json.status 1
  when 'due'
    json.status 2
  when 'cancelled'
    json.status 3
  else
    json.status 0
  end
end
