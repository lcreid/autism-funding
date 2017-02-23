$(document).on('turbolinks:load', function() {
  $('form').areYouSure();
  // Does turbolinks do a proper page unload? No!
});
