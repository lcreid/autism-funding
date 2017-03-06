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
    'invoice_from',
    'service_start',
    'service_end',
    'invoice_date',
    'funded_person_id'
  ];

  // Update Out of Pocket
  out_of_pocket_field = $('#invoice_out_of_pocket');
  invoice_amount_field = $('#invoice_invoice_amount');

  function allocation_fields() {
    a = $('input').filter(function() {
      return this.id.match(/invoice_allocations_attributes_[0-9]+_amount/);
    });
    // console.log(a);
    return a;
  }

  function update_out_of_pocket() {
    allocated_spending = allocation_fields().toArray().reduce(function(a, b) {
      // console.log('update_out_of_pocket b: ' + b.value);
      return b.value === undefined? a: a + Number(b.value.replace(/[,$]/g, ""));
    }, 0);

    // console.log('allocated_spending: ' + allocated_spending);
    // console.log('invoice_amount (string): ' + $('#invoice_invoice_amount').val());
    // console.log('invoice_amount: ' + Number($('#invoice_invoice_amount').val()));
    // console.log('wtf: ' + Number($('#invoice_invoice_amount').val().replace(/,/g, "")) - allocated_spending);
    out_of_pocket =
      Math.max(0,
        Number($('#invoice_invoice_amount').val().replace(/[,$]/g, "")) - allocated_spending);
    // console.log('About to set Out of Pocket to ' + out_of_pocket);
    out_of_pocket_field.val(out_of_pocket.toFixed(2));
  }

  function set_up_triggers() {
    trigger_fields = $.merge($.merge(allocation_fields(),
                                     out_of_pocket_field),
                             invoice_amount_field);
    // console.log('Setting up triggers on ' + trigger_fields);
    trigger_fields.change(function() {
      update_out_of_pocket();
    });
  }

  if (document.getElementById('invoice')) {
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
        // TODO: Check that this doesn't return other people's RTPs
        var request = $.ajax({
          url: "/invoices/rtps",
          data: params,
          method: "GET",
          dataType: "html"
        }).done(function(msg) {
          // console.log(msg);
          // this is where I change the HTML
          $('.cf0925-list-replace').empty();
          // $(msg).appendTo('.cf0925-list-replace');
          $('.cf0925-list-replace').append(msg);
          // console.log('Finished updating select');
          update_out_of_pocket();
          set_up_triggers();
        }).fail(function(xhr, textStatus, errorThrown) {
          if (xhr.status !== 0) {
            console.log("Error: Status: " + textStatus + " error: " + errorThrown);
            console.log("Error: XHR responseXML: " + xhr.responseXML);
            console.log("Error: XHR: " + xhr.status);
          } else {
            // This just means that the user aborted the request, e.g. got tired
            // of waiting and clicked another link before the response came back.
            console.log('Info: User aborted request before response.');
          }
        }).always(function() {
          $('body.pending').removeClass('pending');
          // console.log('Removed .pending');
        });
      });
    });

  set_up_triggers();
  }
});
