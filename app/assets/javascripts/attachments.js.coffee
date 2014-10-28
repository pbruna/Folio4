# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$("#new_attachment button[name=cancel]").click (e) ->
		e.preventDefault()
		$(".attachment-resources a").click()
		$(".attachment-form").hide();
		$("#show-attachment-body").show()
		$("#new_attachment input[type=submit]").attr("disabled", "disabled");
		$("#new_attachment button").attr("disabled", "disabled");
		
	$("#new_attachment input[type=submit]").click (e) ->
		e.preventDefault()
		location.reload()
		
	$("#show-attachment-body a.btn-addfiles").click (e) ->
		$("#show-attachment-body").hide()
		$(".attachment-form").show()
		
	
	delete_attachmment_row = (attachment_id) ->
		$("#attachment-" + attachment_id).fadeOut "slow", ->
		  $("#attachment-" + attachment_id).remove()
		  unless _.any $(".table-attachments .attachment")
		    $(".table-attachments").hide()
		    $("#show-attachment-body").hide()
		    $(".attachment-form").show()
		  
		  
	update_attachment_id = (uuid, attachment_id) ->
		$("#" + uuid).addClass("attachment-uploaded");
		$("#" + uuid + " a").attr("href", "/attachments/" + attachment_id);
		$("#" + uuid).attr("id","attachment-" + attachment_id);
		enable_attachments_form_buttons();
		
	enable_attachments_form_buttons = () ->
		total_attachments = $("#new_attachment .attachment").length
		ready_attachments = $("#new_attachment .attachment-uploaded").length
		result = total_attachments - ready_attachments
		
		if result == 0
			$("#new_attachment input[type=submit]").val("Aceptar");
			$("#new_attachment input[type=submit]").removeAttr("disabled");
			$("#new_attachment button").removeAttr("disabled");
		
		
	Folio.delete_attachmment_row = delete_attachmment_row
	Folio.update_attachment_id = update_attachment_id
		
