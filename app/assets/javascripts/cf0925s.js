$(document).on('turbolinks:load', function() {
  if (document.getElementById('cf0925')) {
    // console.log('Setting up the item total calculations.');
    var item_ids = [
      '#cf0925_item_cost_1',
      '#cf0925_item_cost_2',
      '#cf0925_item_cost_3'
    ].join(', ');

    update_item_total = function() {
      // console.log('Updating the item total: ' + $('#cf0925_item_total').val());
      $('#cf0925_item_total').val($(item_ids).toArray().reduce(function(a, b) {
        // console.log('a, b: ', + a + ', ' + b.value);
        return $.isNumeric(b.value)? a + Number(b.value.replace(/[,$]/g, "")): a;
      }, 0).toFixed(2));
      // console.log('Updated the item total: ' + $('#cf0925_item_total').val());
    };

    // console.log('item_ids: ' + item_ids);
    $(item_ids).change(function() {
      // console.log('Something changed');
      update_item_total();
    });
  }
  // console.log('Done setting up the item total calculations.');
});
