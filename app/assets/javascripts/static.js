$(document).on('turbolinks:load', function() {
  console.log('Loading...');
  $('#help .fixed-nav').affix({
      offset: {
        top: 100,
        bottom: 0
      }
    });
});
