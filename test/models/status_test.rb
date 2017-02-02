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
    set_up_provider_agency_rtp(child, payment: 'provider')

    child.invoices.build(invoice_amount: 1_000,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         invoice_from: 'Ferry Man')

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-02-28',
                         service_end: '2017-02-28',
                         service_start: '2017-02-01',
                         invoice_from: 'Ferry Man')

    child.invoices.build(invoice_amount: 1_000,
                         invoice_date: '2017-03-31',
                         service_end: '2017-03-31',
                         service_start: '2017-03-01',
                         invoice_from: 'Ferry Man')

    child.invoices.each do |i|
      assert(hook_invoice_to_rtp(i), "Failed to match #{i.inspect}")
    end

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
    set_up_provider_agency_rtp(child, payment: 'provider')

    assert_equal 1, child.cf0925s.size

    invoice = child.invoices.build(invoice_amount: 500,
                                   invoice_date: '2017-01-31',
                                   service_end: '2017-01-31',
                                   service_start: '2017-01-01',
                                   invoice_from: 'Ferry Man')

    assert hook_invoice_to_rtp(invoice)

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
    set_up_provider_agency_rtp(child,
                               service_provider_name: 'Pay Me Consultant',
                               payment: 'provider')

    invoice = child.invoices.build(invoice_amount: 500,
                                   invoice_date: '2017-01-31',
                                   service_end: '2017-01-31',
                                   service_start: '2017-01-01',
                                   invoice_from: 'Pay Me Agency')

    hook_invoice_to_rtp(invoice)

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
    set_up_provider_agency_rtp(child,
                               SUPPLIER_ATTRS
                               .merge(created_at: Date.new(2016, 12, 31)))

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         invoice_from: 'Pay Me Agency')

    child.invoices.build(invoice_amount: 1_000,
                         notes: 'WTF?',
                         invoice_date: '2016-12-03',
                         invoice_from: 'Supplier Name')

    child.invoices.each do |i|
      assert(hook_invoice_to_rtp(i), "Failed to match #{i.inspect}")
    end

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
    set_up_provider_agency_rtp(child, service_provider_service_amount: 500)
    set_up_provider_agency_rtp(child,
                               service_provider_service_end: '2017-06-30',
                               service_provider_service_start: '2017-05-01')

    child.invoices.build(invoice_amount: 700,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         invoice_from: 'Pay Me Agency')

    child.invoices.build(invoice_amount: 2_000,
                         invoice_date: '2017-06-30',
                         service_end: '2017-06-30',
                         service_start: '2017-06-01',
                         invoice_from: 'Pay Me Agency')

    child.invoices.each do |i|
      assert(hook_invoice_to_rtp(i), "Failed to match #{i.inspect}")
    end

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 200,
                  spent_funds: 2_500,
                  committed_funds: 2_500,
                  remaining_funds: 3_500)
  end

  test 'need more than one RTP to cover an invoice' do
    skip "This case isn't supported with the current approach."
    child = set_up_child
    set_up_provider_agency_rtp(child, service_provider_service_amount: 500)
    set_up_provider_agency_rtp(child,
                               service_provider_service_amount: 500,
                               service_provider_service_end: '2017-04-30',
                               service_provider_service_start: '2017-04-01')

    child.invoices.build(invoice_amount: 1_100,
                         invoice_date: '2017-05-01',
                         service_end: '2017-04-30',
                         service_start: '2017-01-01',
                         agency_name: 'Pay Me Agency')

    assert_status(child, '2016-2017',
                  spent_out_of_pocket: 100,
                  spent_funds: 1_000,
                  committed_funds: 1_000,
                  remaining_funds: 5_000)
  end

  test 'overlapping RTPs' do
    # FIXME: This case was about the automatic calculation of the optimal
    # way to assign charges to RTPs.
    skip "The test case doesn't work with the current model of assigned RTPs."
    child = set_up_child
    set_up_provider_agency_rtp(child, service_provider_service_amount: 500)
    set_up_provider_agency_rtp(child,
                               service_provider_service_amount: 500,
                               service_provider_service_end: '2017-02-28',
                               service_provider_service_start: '2017-01-01')

    child.invoices.build(invoice_amount: 400,
                         invoice_date: '2016-12-31',
                         service_end: '2016-12-31',
                         service_start: '2016-12-01',
                         agency_name: 'Pay Me Agency')
    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-05-01',
                         service_end: '2017-02-28',
                         service_start: '2017-02-01',
                         agency_name: 'Pay Me Agency')
    child.invoices.build(invoice_amount: 300,
                         invoice_date: '2017-04-30',
                         service_end: '2017-04-30',
                         service_start: '2017-04-01',
                         agency_name: 'Pay Me Agency')
    child.invoices.build(invoice_amount: 1_300,
                         invoice_date: '2017-08-31',
                         service_end: '2017-08-31',
                         service_start: '2017-08-01',
                         agency_name: 'Pay Me Agency')

    # FIXME: The answers won't be right here for the real case.
    child.invoices.each do |i|
      assert(hook_invoice_to_rtp(i), "Failed to match #{i.inspect}")
    end

    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 1_500,
                  spent_funds: 1_000,
                  committed_funds: 1_000,
                  remaining_funds: 5_000)
  end

  # This case was added to test Issue #38
  # I found that I had two different implementations for the same thing.
  # Before I fix it, I want a test to show the failure.
  # The first part of this test comes from
  # test_class_match_RTP_with_provider_only_and_no_payment_specified
  # in test/model/invoice_test.rb.
  test 'invoice and RTP match but invoice paid out of pocket' do
    # params = { invoice_amount: 200,
    #            invoice_date: '2017-08-31',
    #            service_end: '2017-08-31',
    #            service_start: '2017-08-01',
    #            invoice_from: 'A Provider' }
    # assert_equal 1, Invoice.match(child = funded_people(:invoice_to_rtp_match),
    #                               params).size

    child = set_up_child
    set_up_provider_agency_rtp(child,
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
    assert(hook_invoice_to_rtp(invoice), "Failed to match #{invoice.inspect}")
    assert_status(child,
                  '2016-2017',
                  spent_out_of_pocket: 0,
                  spent_funds: 200,
                  committed_funds: 2_000)
  end

  private

  def assert_status(child, fy, statuses)
    status = child.status(fy)
    statuses.each_pair do |k, v|
      assert_equal v, status.send(k), "#{k} failed"
    end
  end

  def hook_invoice_to_rtp(invoice)
    rtps = invoice.match
    return(nil) unless rtps
    invoice.allocate(rtps)
    invoice.save
    # rtps.each { |x| x.invoices << invoice }
  end

  def set_up_child
    user = User.new(email: 'a@example.com',
                    password: 'alsdkfja;s',
                    name_first: 'a',
                    name_last: 'b')
    user.addresses.build(address_line_1: 'a',
                         city: 'b',
                         province_code: province_codes(:bc),
                         postal_code: 'V0V 0V0')
    user.phone_numbers.build(phone_type: 'Home', phone_number: '3334445555')
    user.funded_people.build(name_first: 'a',
                             name_last: 'b',
                             child_in_care_of_ministry: false,
                             birthdate: '2003-11-30')
  end

  SUPPLIER_ATTRS = {
    item_cost_1: 600,
    item_cost_2: 400,
    item_desp_1: 'Conference',
    item_desp_2: 'Workshop',
    supplier_address: 'Supplier St',
    supplier_city: 'Supplier City',
    supplier_contact_person: 'Supplier Contact',
    supplier_name: 'Supplier Name',
    supplier_phone: '8888888888',
    supplier_postal_code: 'V0V 0V0'
  }.freeze

  PROVIDER_AGENCY_ATTRS = {
    agency_name: 'Pay Me Agency',
    payment: 'agency',
    service_provider_postal_code: 'V0V 0V0',
    service_provider_address: '4400 Hastings St.',
    service_provider_city: 'Burnaby',
    service_provider_phone: '7777777777',
    service_provider_name: 'Ferry Man',
    service_provider_service_1: 'Behaviour Consultancy',
    service_provider_service_amount: 2_000,
    service_provider_service_end: '2017-03-31',
    service_provider_service_fee: 120.00,
    service_provider_service_hour: 'Hour',
    service_provider_service_start: '2016-12-01'
  }.freeze

  def set_up_provider_agency_rtp(child, attrs = {})
    set_up_rtp(child, PROVIDER_AGENCY_ATTRS.merge(attrs))
  end

  def set_up_supplier_rtp(child, attrs = {})
    set_up_rtp(child, SUPPLIER_ATTRS.merge(attrs))
  end

  def set_up_rtp(child, attrs)
    rtp = child.cf0925s.build(attrs)
    rtp.populate
    assert rtp.printable?,
           "RTP should be printable #{rtp.errors.full_messages} "\
           "User should be printable #{child.user.errors.full_messages}"

    rtp
  end
end
