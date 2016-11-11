$(document).on('turbolinks:load', function() {
  $('#help .fixed-nav').affix({
      offset: {
        top: 100,
        bottom: 0
      }
    });
});
