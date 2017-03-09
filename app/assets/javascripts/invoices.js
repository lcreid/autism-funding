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
    console.log('allocation_fields returning ' + a.size() + ' fields');
    return a;
  }

  function get_cf0925_invoice_row(e) {
    wdt = 100;
    invoice_row = $(e.target);
    while (wdt > 0 && ! invoice_row.hasClass('test-cf0925-invoice-row') )
      {
      invoice_row = invoice_row.parent();
      wdt--;
      }
    console.log(invoice_row.hasClass('test-cf0925-invoice-row'));
    return(invoice_row);

  }

  function update_invoice_allocation_amount(e) {
    // console.log('Trigger fired at 59.');
    console.log('e: ' + e);
    console.log('e.target: ' + e.target);
    console.log('e.target.id: ' + e.target.id);
    console.log('e.target.value: ' + e.target.value);
    console.log('$(e.target).parent(): ' + $(e.target).parent().html());
    // TODO: Refactor allocated_spending to a function

    // Get the cf0925-invoice_row JQuery object
    invoice_row = get_cf0925_invoice_row(e);
    console.log('Got back from get it ..' + invoice_row.length);
    console.log('invoice_row.find(.amount-available).text()' + invoice_row.find('.amount-available').text());
    amount_available = Number(invoice_row.find('.amount-available').text().replace(/[,$]/g, ""));
    requested_minus_other_invoices = Number(invoice_row.find('.requested-minus-other-invoices').val().replace(/[,$]/g, ""));
    console.log('Amount Available: ' + amount_available + ' .. requested minus: ' + requested_minus_other_invoices)

    // Limit allocation to the invoice amount.
    allocated_spending = allocation_fields().toArray().reduce(function(a, b) {
      // console.log('update_out_of_pocket b: ' + b.value);
      return $.isNumeric(b.value)? a + Number(b.value.replace(/[,$]/g, "")): a;
    }, 0);

    allocation_on_changed_field = e.target.value;
    invoice_amount = Number($('#invoice_invoice_amount').val().replace(/[,$]/g, ""));

    allocated_spending_other_fields = allocated_spending - allocation_on_changed_field;
    available_for_this_invoice = invoice_amount - allocated_spending_other_fields;
console.log('allocation_on_changed_field: ' + allocation_on_changed_field);
    // Limit allocation to the available from RTP.
    // console.log("$(e.target).parent().find('.requested-minus-other-invoices')" + $(e.target).parent().find('.requested-minus-other-invoices'));
    // console.log("$(e.target).parent().find('.requested-minus-other-invoices').attr('nodeType'): " +
    //             $(e.target).parent().find('.requested-minus-other-invoices').attr('nodeType'));
    // requested_minus_other_invoices = Number($(e.target).parent().find('.requested-minus-other-invoices').val().replace(/[,$]/g, ""));
    available_for_this_invoice = Math.min(available_for_this_invoice, requested_minus_other_invoices);
    // Set value.
    if (available_for_this_invoice < allocation_on_changed_field) {
      e.target.value = available_for_this_invoice.toFixed(2);
      console.log('Just set the target to: ' + e.target.value);
    }



    // Set amount available
    // $(e.target).parent().find('.amount_available').text(requested_minus_other_invoices - e.target.value);
    console.log('requested_minus_other_invoices: ' + requested_minus_other_invoices);
    console.log('available_for_this_invoice: ' + available_for_this_invoice);
    amount_available = requested_minus_other_invoices - e.target.value;
//     amount_available = 234;
     invoice_row.find('.amount-available').text(amount_available.toFixed(2))
//     console.log('html 118ish: ' + invoice_row.find('.amount_available').html());
//     amount_available1 = Number(invoice_row.find('.amount_available').text());
//     invoice_row.find('.amount_available').text('111.23');
//     amount_available2 = Number(invoice_row.find('.amount_available').text());
//     console.log('TEXT 120ish: ' + invoice_row.find('.amount_available').text());
//     console.log('Available 1: ' + amount_available1)
//     console.log('Available 2: ' + amount_available2)
// console.log(invoice_row.html());
    console.log('Just set amount available of target to: ' + amount_available);
  }

  function update_out_of_pocket() {
    // TODO: Refactor allocated_spending to a function
    allocated_spending = allocation_fields().toArray().reduce(function(a, b) {
      // console.log('update_out_of_pocket b: ' + b.value);
      return $.isNumeric(b.value)? a + Number(b.value.replace(/[,$]/g, "")): a;
    }, 0);

    invoice_amount = Number($('#invoice_invoice_amount').val().replace(/[,$]/g, ""));

    out_of_pocket = Math.max(0, invoice_amount - allocated_spending);
    console.log('Setting out_of_pocket: ' + out_of_pocket.toFixed(2));
    out_of_pocket_field.val(out_of_pocket.toFixed(2));
  }

  function update_out_of_pocket_for_invoice_amount_change() {
    // console.log('into update_out_of_pocket_for_invoice_amount_change');
    // console.log('Calling triggers on ' + allocation_fields().size() + ' fields');
    allocation_fields().change();
    update_out_of_pocket();
    // console.log('out of update_out_of_pocket_for_invoice_amount_change');
  }

  function set_up_triggers() {
    // trigger_fields = $.merge($.merge(allocation_fields(),
    //                                  out_of_pocket_field));
    console.log('Setting up triggers on ' + allocation_fields().size() + ' fields');
    allocation_fields().change(function(e) {
      // console.log('Trigger fired at 91ish.');
      // console.log(e.target);
      update_invoice_allocation_amount(e);
      update_out_of_pocket();
    });

    invoice_amount_field.change(update_out_of_pocket_for_invoice_amount_change);
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
          set_up_triggers();
          update_out_of_pocket_for_invoice_amount_change();
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
