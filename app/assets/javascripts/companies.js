var typingTimer;                //timer identifier
var doneTypingInterval = 1000;  //time in ms, 5 second for example

var Folio = Folio || {};

$().ready(function() {

	
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