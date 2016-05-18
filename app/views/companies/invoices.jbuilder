json.array! @invoices do |invoice|
  json.number invoice.number
  json.link "http://#{current_account.subdomain}.folio.cl/companies/#{current_account.id}/#{invoice.id}"
  json.date invoice.active_date
  json.total invoice.total.to_i
  json.status invoice.status
end
