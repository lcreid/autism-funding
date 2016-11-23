// Retrieve the RTP that match the data entered on the form so far.
// This means: On changes to provider, agency, supplier, start date, end date,
//  or invoice date, query for matching RTPs.
//  If exactly one is found, return a select drop-down that has the one item
//  selected.
//  If more than one, return the select drop-down with options but none
//  selected.
//  Otherwise, return a select with 'Out of pocket' selected.
