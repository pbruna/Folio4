# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# function remove_fields(link) {
#     $(link).prev("input[type=hidden]").val("1");
#     $(link).parent().parent().find(".item-total").val(0);
#     $(link).closest(".fields").hide();
#     updatePrices();
# }
# 
# function add_fields(link, association, content) {
#         var index = parseInt($("#invoice_items_index").val());
#         var new_index = index + 1;
#         $("#invoice_items_index").val(new_index);
#     var new_id = new Date().getTime();
#         var regexp = new RegExp("_replaceme_", "g");
#     $('#newInvoiceItems').append(content.replace(regexp, index));
# }


$ -> 
	$("#invoice_open_date").datepicker({language: "es", weekStart: 1, autoclose: true})
	
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