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
    // console.log('allocation_fields returning ' + a.size() + ' fields');
    return a;
  }

  function get_cf0925_invoice_row(e) {
    wdt = 100;
    invoice_row = $(e.target);
    //TODO rename class for the invoice row, the class is used for more than testing
    while (wdt > 0 && ! invoice_row.hasClass('test-cf0925-invoice-row') )
      {
      invoice_row = invoice_row.parent();
      wdt--;
      }
    // console.log(invoice_row.hasClass('test-cf0925-invoice-row'));
    return(invoice_row);

  }

  function update_invoice_allocation_amount(e) {
    // This function is called on any change to any value of text boxes in the
    // Amount from This Invoice column in the Assign Request to Pay panel
    //
    // Change to the amount from invoice requires a recalculation of numbers
    // associated with RTP listed on the row where the value changed.  (RTP Changed)

    // This function expects an event object from the text box that changed value
    diag = '\n-- in update_invoice_allocation_amount ----------';

    // Gather required amounts

    // Get the cf0925-invoice_row JQuery object.  This will be the <tr> row associated with the RTP Changed
    invoice_row = get_cf0925_invoice_row(e);

    // This is the RTP Changed Amount Requested less Amounts allocated to other invoices
    // This value is used in calcuations but will not be changed
    requested_minus_other_invoices = Number(invoice_row.find('.requested-minus-other-invoices').val().replace(/[,$]/g, ""));
    diag += '\n  requested_minus_other_invoices: ' + requested_minus_other_invoices;

    // This is the new value the user has entered as Amount From This Invoice
    // This value may need to be updated if the user has allocated more than available
    // The updated value (updated_amount_from_this_invoice) is used throughout the calucations
    // At the end of this, if updated is different from changed, then text box is updated
    changed_amount_from_this_invoice = e.target.value;
    updated_amount_from_this_invoice = changed_amount_from_this_invoice;
    diag += '\n  changed_amount_from_this_invoice: ' + changed_amount_from_this_invoice;

    // Amount available is RTP Changed Requested Amount less requested_minus_other_invoices less changed_amount_from_this_invoice
    // This value is not needed for calculations, but will be recalulated and updated
    amount_available = Number(invoice_row.find('.amount-available').text().replace(/[,$]/g, ""));
    diag += '\n  amount_available (before): ' + amount_available;

    // allocated_spending is the total of all Amount from the Invoice - before any changes or calculations
    // This value is used in calculations, but not updated
    // TODO: Refactor allocated_spending to a function
    allocated_spending = allocation_fields().toArray().reduce(function(a, b) {
      // console.log('update_out_of_pocket b: ' + b.value);
      return $.isNumeric(b.value)? a + Number(b.value.replace(/[,$]/g, "")): a;
    }, 0);
    diag += '\n  allocated_spending: ' + allocated_spending;

    // Invoice amount is the total invoice amount
    // This value is used in calucations but is not changed or updated
    invoice_amount = Number($('#invoice_invoice_amount').val().replace(/[,$]/g, ""));
    diag += '\n  invoice_amount: ' + invoice_amount;


    // 1 - Limit allocation to the invoice amount less other allocations for this invoice ----
    //      (from wiki) The amount is less than than the Invoice Amount minus the other
    //      allocations for the invoice (this is the maximum allowable for this allocation
    //      per the invoice). If not, show a message and reduce the amount to the maximum
    //      allowable for this allocation per the invoice
    allocated_spending_other_fields = allocated_spending - updated_amount_from_this_invoice;
    max_allowable_for_this_allocation_per_invoice = invoice_amount - allocated_spending_other_fields;
    if (max_allowable_for_this_allocation_per_invoice < updated_amount_from_this_invoice) {
      updated_amount_from_this_invoice = max_allowable_for_this_allocation_per_invoice;
      diag += '\n   ---  (1) updated amount_from_this_invoice to: ' + updated_amount_from_this_invoice;
    }

    // 2 - Limit allocation based on requested amount less any allocations to other invoices
    //    (from wiki) The amount is less than the the RTP Amount Requested field, minus the
    //    allocations against the RTP for other invoices (this is the maximum allowable for
    //    this allocation per the RTP. If not, show a message and reduce the amount to the
    //    maximum allowable per the RTP.
    if (requested_minus_other_invoices < updated_amount_from_this_invoice) {
      updated_amount_from_this_invoice = requested_minus_other_invoices;
      diag += '\n   ---  (2) updated amount_from_this_invoice to: ' + updated_amount_from_this_invoice;
    }

    // 3 - Recalculate Amount Available & set it
    amount_available = requested_minus_other_invoices - updated_amount_from_this_invoice;
    invoice_row.find('.amount-available').text(amount_available.toFixed(2));
    diag += '\n   ---  (3) updated amount_available: ' + amount_available;

    // If the amount_from_this_invoice has been changed by these calculations, update it
    if (changed_amount_from_this_invoice != updated_amount_from_this_invoice ) {
        e.target.value =updated_amount_from_this_invoice.toFixed(2);
        diag += '\n   ---  updated amount from this invoice from : ' + changed_amount_from_this_invoice + ' to ' + updated_amount_from_this_invoice;
    }

    diag += '\n';
    // console.log(diag);
  }

  function update_out_of_pocket() {
    // TODO: Refactor allocated_spending to a function
    allocated_spending = allocation_fields().toArray().reduce(function(a, b) {
      // console.log('update_out_of_pocket b: ' + b.value);
      return $.isNumeric(b.value)? a + Number(b.value.replace(/[,$]/g, "")): a;
    }, 0);

    invoice_amount = Number($('#invoice_invoice_amount').val().replace(/[,$]/g, ""));

    out_of_pocket = Math.max(0, invoice_amount - allocated_spending);
    // console.log('Setting out_of_pocket: ' + out_of_pocket.toFixed(2));
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
    // console.log('Setting up triggers on ' + allocation_fields().size() + ' fields');
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
        // console.log ('The Invoice id: ' + $('#invoice_id').val());
        var params = {};
        params['id'] = value_of_element($('#invoice_id')[0]);

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
