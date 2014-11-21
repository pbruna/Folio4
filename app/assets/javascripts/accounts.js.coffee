jQuery ->
	$("#account_name").change ->
		subdomain = $("#account_name").val().replace(/\s+/g, '').toLowerCase();
		$("#account_subdomain").val(subdomain)
		$("#account_subdomain").trigger("change")
		$("#account_subdomain").prop("disabled", false)
		$(".actions input[type='submit']").focus()
	
	$("#account_subdomain").on 'change', ->
		subdomain = $(this).val()
		$.getJSON "/accounts/check_subdomain.json?name=" + subdomain, (response) ->
			if response
				$(".actions input[type='submit']").prop("disabled", false)
				$(".actions input[type='submit']").addClass("btn-primary")
				$(".actions input[type='submit']").removeClass("disable")
			else
				$("#account_subdomain").parent().next().html("<ul role='alert'><li>Subdominio en uso, debes elegir otro.</li></ul>")
				$(".actions input[type='submit']").prop("disabled", true)
				$(".actions input[type='submit']").addClass("disable")
				$(".actions input[type='submit']").removeClass("btn-primary")
	
	$("#account_e_invoice_resolution_date").datepicker({language: "es", weekStart: 1, autoclose: true})