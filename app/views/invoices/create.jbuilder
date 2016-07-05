if @invoice.valid?
  json.id @invoice.id
  json.url "http://#{current_account.subdomain}.folio.cl/invoices/#{@invoice.id}"
else
  json.errors @invoice.errors
end
