var typingTimer;                //timer identifier
var doneTypingInterval = 1000;  //time in ms, 5 second for example

var Folio = Folio || {};

$().ready(function() {

	// $("#company_name_like").keyup(function(){
	//     	typingTimer = setTimeout(doneTyping, doneTypingInterval);
	// });
	// 
	// $("#company_name_like").keydown(function(){
	//     	clearTimeout(typingTimer);
	// });
	// 
	// function doneTyping () {
	// 	var company_name = $("#company_name_like").val();
	// 	$.ajax({
	// 		type: "GET",
	// 		url: "/companies.js",
	// 		data: {company_name_like: $("#company_name_like").val()}
	// 	});	
	// }
	
});

Folio.check_rut_callback = function ($el, value, callback) {
	callback({
	      value: value,
	      valid: Folio.validate_and_format_rut(value,$el),
	      message: "Debes ingresar un RUT válido"
	    });
}

Folio.validate_and_format_rut= function(value,$el){
	$el.Rut();
	return $.Rut.validar(value);
}