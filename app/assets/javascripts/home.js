// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on('turbolinks:load', function() {
  // console.log('loading...');
  $('select.fiscal-year-selector').change(function(event) {
    // console.log('About to submit...');
    $('form.fiscal-year-selector').submit();
    // event.preventDefault();
  });

  // From: http://stackoverflow.com/questions/13778703/adding-open-closed-icon-to-twitter-bootstrap-collapsibles-accordions
  $('.collapse').on('shown.bs.collapse', function() {
    $(this).parent().find(".glyphicon-plus").removeClass("glyphicon-plus").addClass("glyphicon-minus");
  }).on('hidden.bs.collapse', function() {
    $(this).parent().find(".glyphicon-minus").removeClass("glyphicon-minus").addClass("glyphicon-plus");
  });
});
