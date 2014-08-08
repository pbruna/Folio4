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
	
		@id = () ->
			return invoice_item.id
	
		@formatcurrency = (value) ->
			return "$" + value
	
		@total = ko.computed (item, event) =>
			quantity = @quantity()
			if @price() == 0
				price = @price()
			else
				price = @price().replace(/\$\s+/,"").replace(/\./g,"")
				
			(quantity * price).formatMoney(0)
			
class Reminder
	constructor: (reminder) ->
		get_notification_date = (notification_date) ->
			if notification_date == null
				date = new Date
				date.toLocaleDateString()
			else
				notification_date.split(/-/).reverse().join("/")

		@notification_date = ko.observable(get_notification_date(reminder.notification_date))
			

class Invoice
	constructor: (invoice) ->
		
		build_items_array = (items_array) ->
			return [] unless items_array
			items_array.map (item) -> new InvoiceItem item
			
		@addItem = (data, event) ->
			@invoice_items.push(new InvoiceItem {price: "$ 0", quantity: 0, description: "", type: ""})
			$(document).trigger('refresh_autonumeric');
			
		@removeItem = (item) =>
			if @invoice_items().length == 1
				false
			else
				removed = @invoice_items.remove(item)
				item_index = @invoice_items().length
				element_name = "invoice[invoice_items_attributes][" + item_index + "[_destroy]"
				$("#new_invoice_items").append("<input type='hidden' name='" + element_name + "' value=1 />")
				
		@invoice_items = ko.observableArray(build_items_array(invoice.invoice_items))
		@invoice_taxed = ko.observable(invoice.taxed) 
		@invoice_currency = ko.observable(invoice.currency)
		@invoice_company_id = ko.observable(invoice.company_id)
		@invoice_contact_id = ko.observable(invoice.contact_id)
		@reminder = new Reminder invoice.reminder
		
		@invoice_reminder_notification_date_display = ko.computed =>
			org_date = @reminder.notification_date()
			return org_date.split(/\//).splice(0,2).join("/")

		@quantity = ko.observable(0)
		@price = ko.observable(0)			
		
		@invoice_tax_label = ko.computed =>
			if @invoice_taxed() == "false"
				"Exenta"
			else
				"Afecta"
		
		@invoice_contacts = ko.computed =>
			return [] if @invoice_company_id() == (null || "null")
			Folio.getCompanyContacts(@invoice_company_id())
			
		@invoice_contact_selected = ko.computed =>
			if @invoice_contact_id()
				$("#invoice_contact_id option:selected").text();
		
		@invoice_reminder_message = ko.computed =>
			message = "Hola " + @invoice_contact_selected() + ", \n";
			message = message + "El siguiente mensaje es para recordar que tienes una factura que vencerá pronto." 
			message
		
		@show_tax = ko.computed =>
			if @invoice_taxed() == "false"
				false
			else
				true
			
		@invoice_currency_label = ko.computed =>
			@invoice_currency()
			
		@original_currency_total = ko.computed =>
			total = 0
			$.each @invoice_items(), ->
				total += parseInt(@total().replace(/\$\s+/,"").replace(/\./g,""))
				return
			total
		
		@net_total = ko.computed =>
			total = 0
			conversion_rate = Folio.getCurrencyValue(@invoice_currency());
			total = @original_currency_total() * conversion_rate;
			return total
		
		@tax_total = ko.computed =>
			tax_rate = if @show_tax() then 19 else 0
			total = @net_total() * tax_rate / 100
			total 
			
		@invoice_total = ko.computed =>
			total = 0
			if @original_currency_total() < 1
				return total
			else
				conversion_rate = Folio.getCurrencyValue(@invoice_currency());
				total = @net_total() + @tax_total();
				total

window.Invoice = Invoice



$ ->
		# Para ordenar las facturas en el Invoices#Index
		window.sorter_menu_box = (sorted_field) ->
			$(".dropdown-sorter." + sorted_field + " ul li").click () ->
				original_link = $(this).parent().siblings("a")
				selected_link = $(this).children("a")
			
				selected_link_text = selected_link.text()
				original_link_text = original_link.text()
			
				selected_link_sorted_by = selected_link.data(sorted_field)
				original_link_sorted_by = original_link.data(sorted_field)
			
				# Ahora hacemos los cambiamos
				original_link.data(sorted_field, selected_link_sorted_by)
				selected_link.data(sorted_field, original_link_sorted_by)
				original_link.text(selected_link_text)
				selected_link.text(original_link_text)
			
				sorted_direction_selected = $(".dropdown-sorter.sorted-direction a.selected").data("sorted-direction")
				sorted_by_selected = $(".dropdown-sorter.sorted-by a.selected").data("sorted-by")
				search_params = $(".invoices-sorter-menu").data("search-params")
			
				jQuery.ajax({
					url: "/invoices",
					data: search_params + "&search[sorted_direction]="+sorted_direction_selected + "&search[sorted_by]=" + sorted_by_selected,
					dataType: "script"
					})
			
			
		sorter_menu_box("sorted-by")
		sorter_menu_box("sorted-direction")
			
		# Envia la busqueda por estado al elegir un checkbox
		$("#status_search input[type=checkbox]").change () ->
			checkedState = $(this).prop("checked")
			#$(this).parent("div").children(".checkbox:checked").each ->
			$("#invoices-totals-resume-table input[type=checkbox]:checked").each ->
				$(this).prop "checked", false
				
			$(this).prop "checked", checkedState
			$("#search_sorted_by").val($(".dropdown-sorter.sorted-by a.selected").data("sorted-by"))
			$("#search_sorted_direction").val($(".dropdown-sorter.sorted-direction a.selected").data("sorted-direction"))
			$("#status_search").submit()
			
		# Activamos los Tooltips de ayuda en el pago de abonos
		$("#invoice-total .invoice-advances span").tooltip()
		
		autonumeric_options = {aSep: '.', aDec: ',', aSign: '', aPad: "false"}
		# Este if es para que solo se aplique el Binding the Knockout si es que existe
		# el formulario
		if $("#invoice.invoice-form").length > 0
			ko.applyBindings(new Invoice($("#invoice").data("invoice")));
	
		$("#invoice_active_date").datepicker({language: "es", weekStart: 1, autoclose: true})
		$("#invoice_reminder_attributes_notification_date").datepicker({language: "es", weekStart: 1, autoclose: true})
		$(".currency").autoNumeric('init', autonumeric_options)
		
		$("#company_name").bind "railsAutocomplete.select", (event, data) ->
			$("#invoice_company_id").trigger("change")
			return
	
	
		$("#invoice_total_payed").keyup () ->
			payment = $(this).val().replace(/(\$\s+|\.)/ig,"")
			debt = $("#debt").data("debt")
			delta = debt - payment 
			if delta > 0
				$("div[id^='pay-invoice'] input[type=submit]").
				removeClass("btn-primary").addClass("btn-warning").
				val("Abonar pago")
			if delta == 0
				$("div[id^='pay-invoice'] input[type=submit]").
				removeClass("btn-warning").addClass("btn-primary").
				val("Pagar total")
		
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
		
	
	