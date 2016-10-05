// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).on('turbolinks:load', function() {
  // console.log('loading...');
  $('select.fiscal-year-selector').change(function(event) {
    // console.log('About to submit...');
    $('form.fiscal-year-selector').submit();
    // event.preventDefault();
  });
});
