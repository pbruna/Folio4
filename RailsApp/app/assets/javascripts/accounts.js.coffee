jQuery ->
	$("#account_name").change ->
		subdomain = $("#account_name").val().replace(/\s+/g, '').toLowerCase();
		$("#account_subdomain").val(subdomain)
		$("#account_subdomain").prop("disabled", false)
		$(".actions input[type='submit']").focus()
	
	$("#account_subdomain").on 'change', ->
		subdomain = $(this).val()
		$.getJSON "/accounts/check_subdomain.json?name=" + subdomain, (response) ->
			alert("Dominio ocupado") unless response
		