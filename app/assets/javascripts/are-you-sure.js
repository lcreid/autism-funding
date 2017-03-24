$(document).on('turbolinks:load', function() {
  // The following doesn't work IE <= 8
  // NOTE: Don't check for changes on the login page.
  $('form:not(.new_user)').areYouSure();
});
