// Retrieve the RTP that match the data entered on the form so far.
// This means: On changes to provider, agency, supplier, start date, end date,
//  or invoice date, query for matching RTPs.
//  If exactly one is found, return a select drop-down that has the one item
//  selected.
//  If more than one, return the select drop-down with options but none
//  selected.
//  Otherwise, return a select with 'Out of pocket' selected.

$(document).on('turbolinks:load', function() {
  function id_of_interest(attribute) {
    return '#invoice_' + attribute;
  }

  function value_of_element(element) {
    // console.log(element.tagName);
    if (element.tagName == 'TEXTAREA') {
      return element.value;
    } else if (element.tagName == 'INPUT') {
      if (element.type == 'radio' && element.checked) {
        if (!element.value)
          return "on";
        else
          return element.value;
      } else if (element.type == 'checkbox' && element.checked) {
        if (!element.value)
          return "on";
        else
          return element.value;
      } else {
        return element.value;
      }
    } else if (element.tagName == 'SELECT' && element.selectedIndex != -1) {
      return element.options[element.selectedIndex].value;
    }
  }

  attributes_of_interest = [
    'service_provider_name',
    'service_start',
    'service_end',
    'invoice_date',
    'agency_name',
    'supplier_name',
    'funded_person_id'
  ];

  $.map(attributes_of_interest, function(id, key) {
    $(id_of_interest(id)).change(function() {
      // console.log('Something changed.');
      var params = {};
      attributes_of_interest.forEach(function(x) {
        // console.log(x + ': ' + value_of_element($(id_of_interest(x))[0]));
        params[x] = value_of_element($(id_of_interest(x))[0]);
      });

      // path = window.location.pathname;
      // url = path.substr(0, path.lastIndexOf('/'));
      // url = url.substr(0, url.lastIndexOf('/'));
      // console.log(url);

      // console.log('About to look for RTPs: ' + $.param(params));
      var request = $.ajax({
        url: "/invoices/rtps",
        data: params,
        method: "GET",
        dataType: "html"
      }).done(function(msg) {
        // console.log(msg);
        // this is where I change the HTML
        $('.rtp-select option:gt(0)').remove();
        $(msg).appendTo('.rtp-select');
        // console.log('Finished updating select');
      }).fail(function(xhr, textStatus, errorThrown) {
        if (xhr.status !== 0) {
          console.log("Error. Status: " + textStatus + " error: " + errorThrown);
          console.log("XHR responseXML: " + xhr.responseXML);
          console.log("XHR: " + xhr.status);
        } else {
          // This just means that the user aborted the request, e.g. got tired
          // of waiting and clicked another link before the response came back.
          console.log('User aborted request before response.');
        }
      }).always(function() {
        $('body.pending').removeClass('pending');
        // console.log('Removed .pending');
      });
    });
  });
});
