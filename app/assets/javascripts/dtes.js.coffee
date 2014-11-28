# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

check_dte_status = () ->
	invoice_id = $("#invoice").data("invoice-id")
	url = "/dtes/status/" + invoice_id
	procesed = false
	$.getJSON url, (data) ->
		processed = data.processed
		if processed == false
			setTimeout(Folio.check_dte_status,2000)
		else
			location.reload()
		
	
Folio.check_dte_status = check_dte_status

$ ->
	if $("#invoice-total.invoice-status-processing_dte").length > 0
		setTimeout(Folio.check_dte_status, 2000);
		
