# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$("#new_attachment button[name=cancel]").click (e) ->
		e.preventDefault()
		$(".attachment-resources a").click()
		$(".attachment-form").hide();
		$("#show-attachment-body").show()
		
	$("#new_attachment input[type=submit]").click (e) ->
		e.preventDefault()
		# $(".attachment-form").hide();
		# $("#show-attachment-body").show()
		location.reload()
		
	$("#show-attachment-body a.btn-addfiles").click (e) ->
		$("#show-attachment-body").hide()
		$(".attachment-form").show()