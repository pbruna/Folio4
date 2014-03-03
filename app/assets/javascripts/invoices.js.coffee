# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

Number::formatMoney = (c, d, t) ->
  n = this
  c = (if isNaN(c = Math.abs(c)) then 2 else c)
  d = (if d is `undefined` then "," else d)
  t = (if t is `undefined` then "." else t)
  s = (if n < 0 then "-" else "")
  i = parseInt(n = Math.abs(+n or 0).toFixed(c)) + ""
  j = (if (j = i.length) > 3 then j % 3 else 0)
  "$ " + s + ((if j then i.substr(0, j) + t else "")) + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + ((if c then d + Math.abs(n - i).toFixed(c).slice(2) else ""))


class InvoiceItem
	constructor: (invoice_item) ->
		
		@price = ko.observable(parseInt(invoice_item.price).formatMoney(0))
		@quantity = ko.observable(invoice_item.quantity)
		@description = ko.observable(invoice_item.description)
		@type = ko.observable(invoice_item.type)
	
		@formatcurrency = (value) ->
			return "$" + value
	
		@total = ko.computed (item, event) =>
			quantity = @quantity()
			if @price() == 0
				price = @price()
			else
				price = @price().replace(/\$\s+/,"").replace(/\./g,"")
				
			(quantity * price).formatMoney(0)

		

class Invoice
	constructor: (invoice) ->
		
		build_items_array = (items_array) ->
			items_array.map (item) -> new InvoiceItem item
			
		@addItem = (data, event) ->
			@invoice_items.push(new InvoiceItem {price: "$ 0", quantity: 0, description: "", type: ""})
			
		@removeItem = (item) =>
			if @invoice_items().length == 1
				false
			else
				@invoice_items.remove(item)
				
		@invoice_items = ko.observableArray(build_items_array(invoice.invoice_items))
		@invoice_taxed = ko.observable(invoice.taxed) 
		@invoice_currency = ko.observable(invoice.currency)

		@quantity = ko.observable(0)
		@price = ko.observable(0)			

		@invoice_tax_label = ko.computed =>
			if @invoice_taxed() == "false"
				"Exenta"
			else
				"Afecta"
		
		@show_tax = ko.computed =>
			if @invoice_taxed() == "false"
				false
			else
				true
			
		@invoice_currency_label = ko.computed =>
			@invoice_currency()
			
		@invoice_total = ko.computed =>
			total = 0
			$.each @invoice_items(), ->
				total += parseInt(@total().replace(/\$\s+/,"").replace(/\./g,""))
				return
				
			total.formatMoney(0)
			

window.Invoice = Invoice



$ ->
	autonumeric_options = {aSep: '.', aDec: ',', aSign: '$ ', aPad: "false"}
	
	ko.applyBindings(new Invoice($("#invoice").data("invoice")));
	
	$("#invoice_open_date").datepicker({language: "es", weekStart: 1, autoclose: true})
	# $(".currency").autoNumeric('init', autonumeric_options)
	
	
		
	@remove_invoice_item_fields = (link) ->
		return false if $(".invoice-item-fields").size() <= 1
		index = parseInt($("#invoice_items_index").val())
		new_index = index - 1
		$("#invoice_items_index").val new_index
		$(link).prev("input[type=hidden]").val "1"
		$(link).parent().parent().find(".item-total").val 0
		$(link).closest(".invoice-item-fields").remove()
		return
	  
	@add_invoice_item_fields = (link, association, content) ->
		index = parseInt($("#invoice_items_index").val())
		new_index = index + 1
		$("#invoice_items_index").val new_index
		new_id = new Date().getTime()
		regexp = new RegExp("_replaceme_", "g")
		$("#new_invoice_items").append content.replace(regexp, index)
		return
		
	
	