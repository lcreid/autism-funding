require 'test_helper'

class StatusTest < ActiveSupport::TestCase
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
    skip 'Code to pass this test not implemented yet.'
    child = set_up_child
    set_up_provider_agency_rtp(child, payment: 'provider')

    child.invoices.build(invoice_amount: 1_000,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         service_provider_name: 'Ferry Man')

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-02-28',
                         service_end: '2017-02-28',
                         service_start: '2017-02-01',
                         service_provider_name: 'Ferry Man')

    child.invoices.build(invoice_amount: 1_000,
                         invoice_date: '2017-03-31',
                         service_end: '2017-03-31',
                         service_start: '2017-03-01',
                         service_provider_name: 'Ferry Man')

    status = child.status('2016-2017')
    assert_equal 500, status.spent_out_of_pocket
    assert_equal 2_000, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds
  end

  # Test combinations of matching between RTP and invoices.
  test 'invoice from service provider when pay agency' do
    child = set_up_child
    set_up_provider_agency_rtp(child)

    status = child.status('2016-2017')
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         service_provider_name: 'Ferry Man')

    status = child.status('2016-2017')
    assert_equal 500, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds
  end

  test 'invoice from service provider when pay service provider' do
    child = set_up_child
    set_up_provider_agency_rtp(child, payment: 'provider')

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         service_provider_name: 'Ferry Man')

    status = child.status('2016-2017')
    assert_equal 0, status.spent_out_of_pocket
    assert_equal 500, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds
  end

  test 'invoice from service provider but date out of range of RTP' do
    child = set_up_child
    set_up_provider_agency_rtp(child, payment: 'provider')

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2016-11-30',
                         service_end: '2016-11-30',
                         service_start: '2016-11-01',
                         service_provider_name: 'Ferry Man')

    status = child.status('2016-2017')
    assert_equal 0, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds

    status = child.status('2015-2016')
    assert_equal 500, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 0, status.committed_funds
    assert_equal 6_000, status.remaining_funds
  end

  test 'invoice from supplier' do
    skip 'Need a date for supplier-only RTPs.'
    child = set_up_child
    set_up_supplier_rtp(child)

    child.invoices.build(invoice_amount: 1_000,
                         invoice_date: '2016-12-30',
                         supplier_name: 'Supplier Name')

    status = child.status('2016-2017')
    assert_equal 0, status.spent_out_of_pocket
    assert_equal 1_000, status.spent_funds
    assert_equal 1_000, status.committed_funds
    assert_equal 5_000, status.remaining_funds
  end

  test 'invoice from supplier when no supplier RTP' do
    child = set_up_child
    set_up_provider_agency_rtp(child)

    child.invoices.build(invoice_amount: 1_000,
                         invoice_date: '2016-12-30',
                         supplier_name: 'Supplier Name')

    status = child.status('2016-2017')
    assert_equal 1_000, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds
  end

  test 'invoice from supplier when invoice date not in fiscal year' do
    skip 'Need a date for supplier-only RTPs.'
    child = set_up_child
    set_up_supplier_rtp(child)

    child.invoices.build(invoice_amount: 1_000,
                         invoice_date: '2016-11-30',
                         supplier_name: 'Supplier Name')

    status = child.status('2016-2017')
    assert_equal 0, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 1_000, status.committed_funds
    assert_equal 5_000, status.remaining_funds

    status = child.status('2015-2016')
    assert_equal 1_000, status.spent_out_of_pocket
  end

  test 'invoice from agency when pay agency' do
    child = set_up_child
    set_up_provider_agency_rtp(child)

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         agency_name: 'Pay Me Agency')

    status = child.status('2016-2017')
    assert_equal 0, status.spent_out_of_pocket
    assert_equal 500, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds
  end

  test 'invoice from agency when pay provider' do
    child = set_up_child
    set_up_provider_agency_rtp(child,
                               service_provider_name: 'Pay Me Consultant',
                               payment: 'provider')

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2017-01-31',
                         service_end: '2017-01-31',
                         service_start: '2017-01-01',
                         agency_name: 'Pay Me Agency')

    status = child.status('2016-2017')
    assert_equal 500, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds
  end

  test 'invoice from agency but date out of range of RTP' do
    child = set_up_child
    set_up_provider_agency_rtp(child)

    child.invoices.build(invoice_amount: 500,
                         invoice_date: '2016-11-30',
                         service_end: '2016-11-30',
                         service_start: '2016-11-01',
                         agency_name: 'Pay Me Agency')

    status = child.status('2016-2017')
    assert_equal 0, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 2_000, status.committed_funds
    assert_equal 4_000, status.remaining_funds

    status = child.status('2015-2016')
    assert_equal 500, status.spent_out_of_pocket
    assert_equal 0, status.spent_funds
    assert_equal 0, status.committed_funds
    assert_equal 6_000, status.remaining_funds
  end

  test 'both service provider and supplier on one RTP' do
    skip
  end

  test 'need more than one RTP to cover the invoices' do
    skip
  end

  private

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
    service_provider_service_end: '2017-11-30',
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
