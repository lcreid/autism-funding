// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// console.log('loading page in ' + window.location.pathname + '...');
$(document).on('turbolinks:load', function() {
  // $('a').click(function() {
  //   console.log('Clicked a link to go to: ' + this.href + '.');
  // });
  //
  // console.log('loading js in ' + window.location.pathname + '...');
  $('select.fiscal-year-selector').change(function(event) {
    // console.log('Fiscal year change fired. About to submit...');
    $('form.fiscal-year-selector').submit();
    event.preventDefault();
  });

  function set_childs_panel_state(child_id, value) {
    // console.log('Setting panel state: ' + child_id + ' to ' + value);
    $.post('/home/set_panel_state', {
      funded_person_id: child_id,
      panel_state: value
    }, null, "html").done(function(data, textStatus, xhr) {
      // console.log("set_childs_panel_status(0, 100):", data.slice( 0, 100));
    }).fail(function(xhr, textStatus, errorThrown) {
      if (xhr.status !== 0) {
        console.log("Error. Status: " + textStatus + " error: " + errorThrown);
        console.log("XHR responseXML: " + xhr.responseXML);
        console.log("XHR: " + xhr.status);
      } else {
        // This just means that the user aborted the request, e.g. got tired
        // of waiting and clicked another link before the response came back.
        // console.log('User aborted request before response.');
      }
    });
  }

  $('.navbar-collapse').on('shown.bs.collapse', function () {
    console.log("Debug: Opened: " + $(this).attr('id'));
  }).on('hidden.bs.collapse', function () {
    console.log("Debug: Closed: " + $(this).attr('id'));
  });

  // From: http://stackoverflow.com/questions/13778703/adding-open-closed-icon-to-twitter-bootstrap-collapsibles-accordions
  $('.child.panel .collapse').on('shown.bs.collapse', function() {
    // console.log('Shown.');
    $(this).parent().find(".glyphicon-plus").removeClass("glyphicon-plus").addClass("glyphicon-minus");
    // console.log("Opened: " + $(this).attr('data-funded-person-id'));
    set_childs_panel_state($(this).attr('data-funded-person-id'), 'open');
  }).on('hidden.bs.collapse', function() {
    // console.log('Hidden.');
    $(this).parent().find(".glyphicon-minus").removeClass("glyphicon-minus").addClass("glyphicon-plus");
    // console.log("Closed: " + $(this).attr('data-funded-person-id'));
    set_childs_panel_state($(this).attr('data-funded-person-id'), 'closed');
  // }).on('show.bs.collapse', function() {
  //   console.log('Showing.');
  //   $(this).parent().find(".glyphicon-plus").removeClass("glyphicon-plus").addClass("glyphicon-minus");
  // }).on('hide.bs.collapse', function() {
  //   console.log('Hiding.');
  //   $(this).parent().find(".glyphicon-minus").removeClass("glyphicon-minus").addClass("glyphicon-plus");
  });
  //
  // console.log('Done the turbolinks:load.');
});
