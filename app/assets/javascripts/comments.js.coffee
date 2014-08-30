# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

	$(".comment-selectable-subscriber-checkbox").on "change", () ->
      update_organizations_labels()

	$(document).on "change", "#comment_private", () ->
      if $(this).prop "checked"
        $("[data-organization-type='company']").hide()
      else
        $("[data-organization-type='company']").show()


	change_organization_label = (checked, org_id) ->
	  org_label = $(".label-select-organization")
	  org_label = $(".label-select-organization[data-organization-id='#{org_id}']") if org_id
	  if checked
		  org_label.removeClass("disable")
		  org_label.addClass("enable")
	  else
		  org_label.removeClass("enable")
		  org_label.addClass("disable")

	count_subscribers_per_organization = (org_id) ->
	  $(".comment-selectable-subscriber-checkbox[data-subscriber-organization-id='#{org_id}']").length

	count_selected_subscribers_per_organization = (org_id) ->
	  $(".comment-selectable-subscriber-checkbox[data-subscriber-organization-id='#{org_id}']:checkbox:checked").length
	
	all_organization_selectd = (org_id) ->
	  result = count_subscribers_per_organization(org_id) - count_selected_subscribers_per_organization(org_id)
	  return true if result == 0 
	  return false

	toggle_subscribers = (e, checked) ->
	  e.preventDefault()
	  $(".comment-selectable-subscriber-checkbox").each ->
	    $(this).prop "checked", checked
  	  change_organization_label(checked)
	  return
	  
	update_organizations_labels = () ->
	  orgs_ids = []
	  $("#new_comment a[data-behavior=subscriber_select_organization]").each ->
		  orgs_ids.push $(this).data("organization-id")
	  _.each orgs_ids, (org_id) ->
		  checked = all_organization_selectd(org_id)
		  change_organization_label(checked, org_id)
	
	update_organizations_labels()
	
	window.update_organizations_labels = () ->
		update_organizations_labels()
	
	$(document).on "click", "#new_comment a[data-behavior=subscriber_select_all]", (e) ->
	  toggle_subscribers(e, true)
	  
	$(document).on "click", "#new_comment a[data-behavior=subscriber_select_none]", (e) ->
	  toggle_subscribers(e, false)
	  
	$(document).on "click", "#new_comment a[data-behavior=subscriber_select_organization]", (e) ->
	  e.preventDefault()
	  org_id = $(this).data("organization-id")
	  checked = !all_organization_selectd(org_id)
	  $(".comment-selectable-subscriber-checkbox").each ->
		  if $(this).data("subscriber-organization-id") == org_id
			  $(this).prop "checked", checked
		  return
	  change_organization_label(checked, org_id)
	  return

