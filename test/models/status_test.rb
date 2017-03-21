require 'test_helper'

# FIXME: Need to do a better job of ensuring adequate test coverage. What's
# here isn't enough.

class StatusTest < ActiveSupport::TestCase
  include TestSessionHelpers
  test 'status one year' do
    child = funded_people(:two_fiscal_years)
    status_2016 = child.status('2015-2016')
    assert_equal 200, status_2016.spent_funds
    assert_equal 2_500, status_2016.committed_funds
    assert_equal 3_500, status_2016.remaining_funds
    assert_equal 0, status_2016.spent_out_of_pocket
  end

  test 'status next year' do
    child = funded_people(:two_fiscal_years)
    status_2017 = child.status('2016-2017')
    assert_equal 0, status_2017.spent_funds
    assert_equal 3_000, status_2017.committed_funds
    assert_equal 3_000, status_2017.remaining_funds
    assert_equal 0, status_2017.spent_out_of_pocket
  end

  test 'statuses are different' do
    child = funded_people(:two_fiscal_years)
    status_2016 = child.status('2015-2016')
    status_2017 = child.status('2016-2017')
    assert_not_equal status_2016, status_2017
  end

  test 'child under 6' do
    child = funded_people(:four_year_old)
    status = child.status('2016-2017')
    assert_equal 22_000, status.allowable_funds_for_year
  end

  test 'child 6 and over' do
    child = funded_people(:sixteen_year_old)
    status = child.status(child.fiscal_year(Date.new(2016, 6, 1)))
    assert_equal 6_000, status.allowable_funds_for_year
  end

  test 'too old for funding' do
    child = funded_people(:sixteen_year_old)
    status = child.status(child.fiscal_year(Date.new(2018, 6, 1)))
    assert_equal 0, status.allowable_funds_for_year
  end

  test 'not born yet' do
    child = funded_people(:four_year_old)
    status = child.status(child.fiscal_year(Date.new(2012, 2, 29)))
    assert_equal 0, status.allowable_funds_for_year
  end

  test 'big spender spent more than requested' do
    # skip 'Code to pass this test not implemented yet.'
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child, payment: 'provider')

    i = child.invoices.build(invoice_amount: 1_000,
                             invoice_date: '2017-01-31',
                             service_end: '2017-01-31',
                             service_start: '2017-01-01',
                             invoice_from: 'Ferry Man')
    # We have to explicitly save the invoice because we don't have
    # autosave: true from InvoiceAllocation to Invoice.
    i.connect(rtp, 'ServiceProvider', 1_000)
    i.save!

    i = child.invoices.build(invoice_amount: 500,
                             invoice_date: '2017-02-28',
                             service_end: '2017-02-28',
                             service_start: '2017-02-01',
                             invoice_from: 'Ferry Man')
    i.connect(rtp, 'ServiceProvider', 500)
    i.save!

    i = child.invoices.build(invoice_amount: 1_000,
                             invoice_date: '2017-03-31',
                             service_end: '2017-03-31',
                             service_start: '2017-03-01',
                             invoice_from: 'Ferry Man')
    i.connect(rtp, 'ServiceProvider', 500)
    i.save!

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 500,
                  spent_funds: 2_000,
                  committed_funds: 2_000,
                  remaining_funds: 4_000)
  end

  # Test combinations of matching between RTP and invoices.
  # Payment flag is no longer a criteria for matching, so commenting this out.
  # test 'invoice from service provider when pay agency' do
  #   child = set_up_child
  #   set_up_provider_agency_rtp(child)
  #
  #   assert_status(child,
  #                 '2016-2017',
  #                 remaining_funds: 4_000,
  #                 committed_funds: 2_000)
  #
  #   invoice = child.invoices.build(invoice_amount: 500,
  #                                  invoice_date: '2017-01-31',
  #                                  service_end: '2017-01-31',
  #                                  service_start: '2017-01-01',
  #                                  invoice_from: 'Ferry Man')
  #
  #   hook_invoice_to_rtp(invoice)
  #
  #   assert_status(child,
  #                 '2016-2017',
  #                 spent_out_of_pocket: 500,
  #                 spent_funds: 0,
  #                 committed_funds: 2_000,
  #                 remaining_funds: 4_000)
  # end

  test 'invoice from service provider when pay service provider' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child, payment: 'provider')

    assert_equal 1, child.cf0925s.size

    invoice = child.invoices.build(invoice_amount: 500,
                                   invoice_date: '2017-01-31',
                                   service_end: '2017-01-31',
                                   service_start: '2017-01-01',
                                   invoice_from: 'Ferry Man')

    invoice.connect(rtp, 'ServiceProvider', 500)
    invoice.save!

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 500,
                  committed_funds: 2_000,
                  remaining_funds: 4_000)
  end

  test 'invoice from service provider but date out of range of RTP' do
    child = set_up_child
    set_up_provider_agency_rtp(child, payment: 'provider')

    invoice = child.invoices.build(invoice_amount: 500,
                                   invoice_date: '2016-11-30',
                                   service_end: '2016-11-30',
                                   service_start: '2016-11-01',
                                   invoice_from: 'Ferry Man')

    assert_no_difference 'InvoiceAllocation.count' do
      hook_invoice_to_rtp(invoice)
    end

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 0,
                  committed_funds: 2_000,
                  remaining_funds: 4_000)

    assert_status(child,
                  '2015-2016',
                  spent_out_of_pocket: 500,
                  spent_funds: 0,
                  committed_funds: 0,
                  remaining_funds: 6_000)
  end

  test 'invoice from supplier' do
    skip 'Need a date for supplier-only RTPs.'
    child = set_up_child
    set_up_supplier_rtp(child)

    invoice = child.invoices.build(invoice_amount: 1_000,
                                   invoice_date: '2016-12-30',
                                   supplier_name: 'Supplier Name')

    hook_invoice_to_rtp(invoice)

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 1_000,
                  committed_funds: 1_000,
                  remaining_funds: 5_000)
  end

  test 'invoice from supplier when no supplier RTP' do
    child = set_up_child
    set_up_provider_agency_rtp(child)

    invoice = child.invoices.build(invoice_amount: 1_000,
                                   invoice_date: '2016-12-30',
                                   invoice_from: 'Supplier Name')

    hook_invoice_to_rtp(invoice)

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 1_000,
                  spent_funds: 0,
                  committed_funds: 2_000,
                  remaining_funds: 4_000)
  end

  test 'invoice from supplier when invoice date not in fiscal year' do
    # FIXME: we should be using the part_b_fiscal_year now.
    skip 'Need a date for supplier-only RTPs.'
    child = set_up_child
    set_up_supplier_rtp(child)

    invoice = child.invoices.build(invoice_amount: 1_000,
                                   invoice_date: '2016-11-30',
                                   supplier_name: 'Supplier Name')

    hook_invoice_to_rtp(invoice)

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 0,
                  committed_funds: 1_000,
                  remaining_funds: 5_000)

    assert_status(child,
                  '2015-2016',
                  spent_out_of_pocket: 1_000)
  end

  test 'invoice from agency when pay agency' do
    child = set_up_child
    set_up_provider_agency_rtp(child)

    invoice = child.invoices.build(invoice_amount: 500,
                                   invoice_date: '2017-01-31',
                                   service_end: '2017-01-31',
                                   service_start: '2017-01-01',
                                   invoice_from: 'Pay Me Agency')

    assert hook_invoice_to_rtp(invoice)

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 500,
                  committed_funds: 2_000,
                  remaining_funds: 4_000)
  end

  test 'invoice from agency when pay provider' do
    skip 'Matching no longer takes into account the payment attribute of the RTP'
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
                                     service_provider_name: 'Pay Me Consultant',
                                     payment: 'provider')

    invoice = child.invoices.build(invoice_amount: 500,
                                   invoice_date: '2017-01-31',
                                   service_end: '2017-01-31',
                                   service_start: '2017-01-01',
                                   invoice_from: 'Pay Me Agency')

    hook_invoice_to_rtp(invoice)
    assert_equal 0, invoice.cf0925s.size
    assert_equal 0, rtp.invoices.size
    # byebug # rubocop:disable Lint/Debugger

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 500,
                  spent_funds: 0,
                  committed_funds: 2_000,
                  remaining_funds: 4_000)
  end

  test 'invoice from agency but date out of range of RTP' do
    child = set_up_child
    set_up_provider_agency_rtp(child)

    invoice = child.invoices.build(invoice_amount: 500,
                                   invoice_date: '2016-11-30',
                                   service_end: '2016-11-30',
                                   service_start: '2016-11-01',
                                   invoice_from: 'Pay Me Agency')

    hook_invoice_to_rtp(invoice)

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 0,
                  committed_funds: 2_000,
                  remaining_funds: 4_000)

    assert_status(child,
                  '2015-2016',
                  spent_out_of_pocket: 500,
                  spent_funds: 0,
                  committed_funds: 0,
                  remaining_funds: 6_000)
  end

  test 'both service provider and supplier on one RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
                                     SUPPLIER_ATTRS
                                     .merge(created_at: Date.new(2016, 12, 31)))

    i = child.invoices.build(invoice_amount: 500,
                             invoice_date: '2017-01-31',
                             service_end: '2017-01-31',
                             service_start: '2017-01-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp, 'ServiceProvider', 500)
    i.save!

    i = child.invoices.build(invoice_amount: 1_000,
                             invoice_date: '2016-12-03',
                             invoice_from: 'Supplier Name')
    i.connect(rtp, 'Supplier', 1_000)
    i.save!

    #    show_matching_info child

    assert 2, child.cf0925s.first.invoices.size

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 1_500,
                  committed_funds: 3_000,
                  remaining_funds: 3_000)
  end

  test 'multiple RTPs, multiple invoices' do
    child = set_up_child
    rtp_a = set_up_provider_agency_rtp(child, service_provider_service_amount: 500)
    rtp_b = set_up_provider_agency_rtp(child,
                                       service_provider_service_end: '2017-06-30',
                                       service_provider_service_start: '2017-05-01')

    i = child.invoices.build(invoice_amount: 700,
                             invoice_date: '2017-01-31',
                             service_end: '2017-01-31',
                             service_start: '2017-01-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp_a, 'ServiceProvider', 500)
    i.save!

    i = child.invoices.build(invoice_amount: 2_000,
                             invoice_date: '2017-06-30',
                             service_end: '2017-06-30',
                             service_start: '2017-06-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp_b, 'ServiceProvider', 2_000)
    i.save!

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 200,
                  spent_funds: 2_500,
                  committed_funds: 2_500,
                  remaining_funds: 3_500)
  end

  test 'need more than one RTP to cover an invoice' do
    child = set_up_child
    rtp_a = set_up_provider_agency_rtp(child, service_provider_service_amount: 500)
    rtp_b = set_up_provider_agency_rtp(child,
                                       service_provider_service_amount: 500,
                                       service_provider_service_end: '2017-04-30',
                                       service_provider_service_start: '2017-04-01')

    i = child.invoices.build(invoice_amount: 1_100,
                             invoice_date: '2017-05-01',
                             service_end: '2017-04-30',
                             service_start: '2017-01-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp_a, 'ServiceProvider', 500)
    i.connect(rtp_b, 'ServiceProvider', 500)
    i.save!

    assert_status(child, '2016-2017',
                  spent_out_of_pocket: 100,
                  spent_funds: 1_000,
                  committed_funds: 1_000,
                  remaining_funds: 5_000)
  end

  test 'overlapping RTPs' do
    child = set_up_child
    rtp_a = set_up_provider_agency_rtp(child, service_provider_service_amount: 500)
    rtp_b = set_up_provider_agency_rtp(child,
                                       service_provider_service_amount: 500,
                                       service_provider_service_end: '2017-02-28',
                                       service_provider_service_start: '2017-01-01')

    i = child.invoices.build(invoice_amount: 400,
                             invoice_date: '2016-12-31',
                             service_end: '2016-12-31',
                             service_start: '2016-12-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp_a, 'ServiceProvider', 400)
    i.save!
    i = child.invoices.build(invoice_amount: 500,
                             invoice_date: '2017-05-01',
                             service_end: '2017-02-28',
                             service_start: '2017-02-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp_a, 'ServiceProvider', 100)
    i.connect(rtp_b, 'ServiceProvider', 400)
    i.save!
    assert i.include_in_reports?
    i = child.invoices.build(invoice_amount: 300,
                             invoice_date: '2017-03-31',
                             service_end: '2017-03-31',
                             service_start: '2017-03-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp_b, 'ServiceProvider', 100)
    i.save!
    child.invoices.create(invoice_amount: 1_300,
                          invoice_date: '2017-08-31',
                          service_end: '2017-08-31',
                          service_start: '2017-08-01',
                          invoice_from: 'Pay Me Agency')

    assert_equal 2, child.cf0925s.size
    assert_equal 4, child.invoices.size
    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 1_500,
                  spent_funds: 1_000,
                  committed_funds: 1_000,
                  remaining_funds: 5_000)
  end

  test 'invoice and RTP match but invoice paid out of pocket' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
                                     service_provider_service_amount: 2_000,
                                     service_provider_service_end: '2017-09-30',
                                     service_provider_service_start: '2017-07-01',
                                     payment: nil,
                                     agency_name: nil)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2017-08-31',
                                   service_end: '2017-08-31',
                                   service_start: '2017-08-01',
                                   invoice_from: 'Ferry Man')
    invoice.connect(rtp, 'ServiceProvider')
    invoice.save!
    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 200,
                  spent_funds: 0,
                  committed_funds: 2_000)
  end

  test 'RTP has parts A and B ' \
    'Invoice for A is more than requested ' \
    'Invoice for B is less than requested' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
                                     SUPPLIER_ATTRS
                                     .merge(created_at: Date.new(2016, 12, 31)))

    i = child.invoices.build(invoice_amount: 2_500,
                             invoice_date: '2017-01-31',
                             service_end: '2017-01-31',
                             service_start: '2017-01-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp, 'ServiceProvider', 2_000)
    i.save!

    i = child.invoices.build(invoice_amount: 500,
                             invoice_date: '2016-12-03',
                             invoice_from: 'Supplier Name')
    i.connect(rtp, 'Supplier', 500)
    i.save!

    #    show_matching_info child

    assert 2, child.cf0925s.first.invoices.size

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 500,
                  spent_funds: 2_500,
                  committed_funds: 3_000,
                  remaining_funds: 3_000)
  end

  test 'RTP has parts A and B ' \
    'Invoice for A is less than requested ' \
    'Invoice for B is more than requested' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child,
                                     SUPPLIER_ATTRS
                                     .merge(created_at: Date.new(2016, 12, 31)))

    i = child.invoices.build(invoice_amount: 1_500,
                             invoice_date: '2017-01-31',
                             service_end: '2017-01-31',
                             service_start: '2017-01-01',
                             invoice_from: 'Pay Me Agency')
    i.connect(rtp, 'ServiceProvider', 1_500)
    i.save!

    i = child.invoices.build(invoice_amount: 1_400,
                             invoice_date: '2016-12-03',
                             invoice_from: 'Supplier Name')
    i.connect(rtp, 'Supplier', 1_000)
    # FIXME: Make the `build` into `create` and maybe we don't need the save!
    i.save!

    #    show_matching_info child

    assert 2, rtp.invoice_allocations.size

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 400,
                  spent_funds: 2_500,
                  committed_funds: 3_000,
                  remaining_funds: 3_000)
  end

  private

  def assert_status(child, fy, statuses)
    status = child.status(fy)
    statuses.each_pair do |k, v|
      assert_equal v, status.send(k), "#{k} failed"
    end
  end

  # Assumes you're setting up raw data, so it can bypass the full allocation
  # logic and just connect the invoice to the RTPs. It breaks on cases where
  # more than one RTP matches.
  def hook_invoice_to_rtp(invoice)
    rtps = invoice.match
    return(nil) unless rtps
    rtps.each do |match|
      invoice.connect(match.cf0925, match.cf0925_type, invoice.invoice_amount)
    end
    invoice.save
    # rtps.each { |x| x.invoices << invoice }
  end
end
