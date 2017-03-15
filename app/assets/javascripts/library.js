// Produce the weit standard number format with two decimal.
function format_number(n) {
  return n.toFixed(2);
  // return Number(n).toLocaleString('en-CA', {
  //   minimumFractionDigits: 2, maximumFractionDigits: 2
  // });
}

// Convert a human-readable number in a string to a number,
function unformat_number(s) {
  s = s.replace(/[^0-9.]/g, "");
  return $.isNumeric(s)? Number(s): 0;
}
