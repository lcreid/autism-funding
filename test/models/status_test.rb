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

  test 'big spender spent more than limit' do
    skip
  end

  test 'big spender spent more than requested' do
  end

  # Test combinations of matching between RTP and invoices.
  test 'invoice from service provider when pay agency' do
    user = User.new(email: 'a@example.com',
                    name_first: 'a',
                    name_last: 'b')
    user.addresses.build(address_line_1: 'a',
                         city: 'b',
                         province_code: province_codes(:bc),
                         postal_code: 'V0V 0V0')
    user.phone_numbers.build(phone_type: 'Home', phone_number: '3334445555')
    child = user.funded_people.build(name_first: 'a',
                                     name_last: 'b',
                                     birthdate: '2003-11-30')
    rtp = child.cf0925s.build(form: forms(:cf0925),
                              agency_name: 'Pay Me Agency',
                              payment: 'agency',
                              service_provider_postal_code: 'V0V 0V0',
                              service_provider_address: '4400 Hastings St.',
                              service_provider_city: 'Burnaby',
                              service_provider_phone: '7777777777',
                              service_provider_name: 'Ferry Man',
                              service_provider_service_1: 'Behaviour Consultancy',
                              service_provider_service_amount: 3_000,
                              service_provider_service_end: '2017-11-30',
                              service_provider_service_fee: 120.00,
                              service_provider_service_hour: 'Hour',
                              service_provider_service_start: '2016-12-01')

    assert rtp.printable?, "RTP should be printable #{rtp.errors.full_messages}"
  end

  test 'invoice from service provider when pay service provider' do
  end

  test 'invoice from service provider but date out of range of RTP' do
  end

  test 'invoice from supplier' do
  end

  test 'invoice from supplier when no supplier' do
  end

  test 'invoice from supplier when invoice date no in fiscal year' do
  end

  test 'invoice from agency when pay agency' do
  end

  test 'invoice from agency when pay provider' do
  end

  test 'invoice from agency but date out of range of RTP' do
  end
end
