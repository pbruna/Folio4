// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery.Rut.min
//= require autocomplete-rails
//= require bootstrap
//= require bootstrap-datepicker
//= require bootstrap-datepicker.es.js
//= require jqBootstrapValidation
//= require autonumeric
//= require knockout
//= require bootstrap.file-input
//= require jquery.remotipart
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require underscore
//= require jquery-uuid
//= require pagination
//= require_tree .

var Folio = Folio || {};

$(function () { 
	$("input,select,textarea").not("[type=submit],.no-validate").jqBootstrapValidation({autoAdd: {helpBlocks: false, helpInline: true}});
	$('.file-inputs').bootstrapFileInput();
	
	// Mostramos el calendario cuando deben seleccionar una fecha
	$(".date-input").datepicker({language: "es", weekStart: 1, autoclose: true})


	// Funcion para submit form apretando el boton
	// del footer de un modal.
	$("button[data-submit='submit']").click(function() {
		var form = $(this).data("formid");
		$("#"+form).submit();
	});
	
	$("#edit-company-contact-modal button[data-submit='submit']").click(function() {
		$("form[id^='edit_contact_']").submit();
	});

	// Esto permite que un modal que carga datos remotos
	// se destruya cuando se presione cancelar, y que al 
	// mostrarlo de nuevo empiece con una ventana limpia
	$(".modal").on('hidden', function(){$(this).removeData('modal')})
	
	// Esto permite activar el tab correspondiente en las facturas
	var url = document.location.toString();
	if (url.match(/#\w+/)) {
	    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show') ;
	} 

	// Change hash for page-reload
	$('.nav-tabs a').on('shown', function (e) {
	    window.location.hash = e.target.hash;
	})
	
	// # Agrega la clase invoices-index-autocomplete al autocomplete de nombre de la empresa
	// # en Invoice#Index Sidebar
	
	$(".invoices-index-autocomplete").autocomplete().autocomplete("widget").addClass("invoices-index-autocomplete");

});

Folio.getCurrencyValue = function(currency) {
	value = $("#" + currency.toLowerCase() + "-conversion-rate").attr("data-value");
	return parseFloat(value);
}

Folio.getDolarValue = function(){
	return Folio.getCurrencyValue("usd");
}

Folio.getUfValue = function(){
	return Folio.getCurrencyValue("uf");
}

Folio.getCompanyContacts = function(company_id) {
	var contacts = [];
	json_url = "/contacts?company_id=" + company_id;
	$.ajax({
          url: json_url,
		  async: false,
		  dataType: 'json',
          type: 'GET',
          success: function(data){
	  		$.each(data, function(k,v){
	  			contacts.push(v);
	  		})
          }
       });
	return contacts;
}
