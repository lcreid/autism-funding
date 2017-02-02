require 'test_helper'

class Cf0925Test < ActiveSupport::TestCase
  test 'generation of a PDF' do
    unless ENV['TEST_PDF_GENERATION']
      skip 'Skipping PDF generation. To include: `export TEST_PDF_GENERATION=1`'
    end
    rtp = cf0925s(:one)
    assert rtp.generate_pdf
    assert File.exist?(rtp.pdf_output_file), "File #{rtp.pdf_output_file} not found"
  end

  test 'not printable' do
    rtp = cf0925s(:minimum_printable)
    rtp.parent_last_name = nil
    assert !rtp.printable?, 'should be not printable'
    assert 1, rtp.errors.size
    assert 'Fill in Part A or Part B or both.',
           rtp.errors[:hints]
  end

  test 'fiscal year' do
    rtp = cf0925s(:one)
    assert_equal Date.new(2016, 5, 1)..Date.new(2017, 4, 30),
                 rtp.fiscal_year
  end

  test 'dates are not in one fiscal year' do
    rtp = Cf0925.new
    rtp.funded_person = funded_people(:dob_2003_01_01)
    rtp.service_provider_service_start = Date.new(2008, 1, 31)
    rtp.service_provider_service_end = Date.new(2008, 2, 1)
    rtp.printable?
    assert_equal ['service end date must be in the same fiscal year ' \
                 'as service start date'],
                 rtp.errors[:service_provider_service_end]
  end

  test 'dates are in one fiscal year' do
    rtp = Cf0925.new
    rtp.funded_person = funded_people(:dob_2003_01_01)
    rtp.service_provider_service_start = Date.new(2008, 2, 1)
    rtp.service_provider_service_end = Date.new(2009, 1, 31)
    rtp.printable?
    assert rtp.errors[:service_provider_service_end].empty?,
           -> {
             'Expected no error message. ' \
             "Got #{rtp.errors[:service_provider_service_end]}"
           }
  end

  test 'store numbers' do
    rtp = Cf0925.new(service_provider_service_amount: '2000')
    assert_equal 2_000, rtp.service_provider_service_amount
    rtp.update(service_provider_service_amount: '2000.50')
    assert_equal 2_000.50, rtp.service_provider_service_amount
    rtp.update(service_provider_service_amount: '2,000.50')
    assert_equal 2_000.50, rtp.service_provider_service_amount
  end

  test 'empty form' do
    rtp = prep_empty_form

    assert !rtp.printable?, 'should be not printable'
    assert_equal 1, rtp.errors.size, rtp.errors.full_messages
    assert_equal ['Fill in Part A or Part B or both.'], rtp.errors[:base]
  end

  test 'Missing one item from Part A' do
    rtp = prep_empty_form
    rtp.update(agency_name: 'Disable Clinic',
               payment: 'provider',
               service_provider_postal_code: 'V0V 0V0',
               service_provider_address: 'Way St',
               service_provider_city: 'Way Way',
               #  service_provider_phone: '5555551212',
               service_provider_name: 'B Intervention',
               service_provider_service_1: 'Behaviour Intervention',
               service_provider_service_amount: '1,000',
               service_provider_service_end: '2017-02-28',
               service_provider_service_fee: '100',
               service_provider_service_hour: 'hour',
               service_provider_service_start: '2016-10-01'
              )
    assert !rtp.printable?, 'should be not printable'
    assert_equal 1, rtp.errors.size, rtp.errors.full_messages
    assert_equal ["can't be blank"], rtp.errors[:service_provider_phone]
  end

  test 'Ask for payment when both provider and agency' do
    rtp = prep_empty_form
    rtp.update(agency_name: 'Disable Clinic',
               #  payment: 'provider',
               service_provider_postal_code: 'V0V 0V0',
               service_provider_address: 'Way St',
               service_provider_city: 'Way Way',
               service_provider_phone: '5555551212',
               service_provider_name: 'B Intervention',
               service_provider_service_1: 'Behaviour Intervention',
               service_provider_service_amount: '1,000',
               service_provider_service_end: '2017-02-28',
               service_provider_service_fee: '100',
               service_provider_service_hour: 'hour',
               service_provider_service_start: '2016-10-01'
              )
    assert !rtp.printable?, 'should be not printable'
    assert_equal 1, rtp.errors.size, rtp.errors.full_messages
    assert_equal ['please choose either service provider or agency'],
                 rtp.errors[:payment]
  end

  test "Don't insist on payment when provider only" do
    rtp = prep_empty_form
    rtp.update(service_provider_postal_code: 'V0V 0V0',
               service_provider_address: 'Way St',
               service_provider_city: 'Way Way',
               service_provider_phone: '5555551212',
               service_provider_name: 'B Intervention',
               service_provider_service_1: 'Behaviour Intervention',
               service_provider_service_amount: '1,000',
               service_provider_service_end: '2017-02-28',
               service_provider_service_fee: '100',
               service_provider_service_hour: 'hour',
               service_provider_service_start: '2016-10-01'
              )

    assert rtp.printable?,
           rtp.errors.full_messages + rtp.user.errors.full_messages
    # assert_equal 'provider', rtp.payment
  end

  test "Don't insist on payment when agency only" do
    rtp = prep_empty_form
    rtp.update(agency_name: 'Disable Clinic',
               service_provider_postal_code: 'V0V 0V0',
               service_provider_address: 'Way St',
               service_provider_city: 'Way Way',
               service_provider_phone: '5555551212',
               service_provider_service_1: 'Behaviour Intervention',
               service_provider_service_amount: '1,000',
               service_provider_service_end: '2017-02-28',
               service_provider_service_fee: '100',
               service_provider_service_hour: 'hour',
               service_provider_service_start: '2016-10-01'
              )

    assert rtp.printable?,
           rtp.errors.full_messages + rtp.user.errors.full_messages
    # assert_equal 'agency', rtp.payment
  end

  test 'Must have one or agency or service provider name' do
    rtp = prep_empty_form
    rtp.update(service_provider_postal_code: 'V0V 0V0',
               service_provider_address: 'Way St',
               service_provider_city: 'Way Way',
               service_provider_phone: '5555551212',
               service_provider_service_1: 'Behaviour Intervention',
               service_provider_service_amount: '1,000',
               service_provider_service_end: '2017-02-28',
               service_provider_service_fee: '100',
               service_provider_service_hour: 'hour',
               service_provider_service_start: '2016-10-01'
              )

    assert !rtp.printable?, 'should be not printable'
    assert_equal 2, rtp.errors.size, rtp.errors.full_messages

    rtp.update(agency_name: 'Disable Clinic')
    assert rtp.printable?, rtp.errors.full_messages

    rtp.update(agency_name: '', service_provider_name: 'B Intervention')
    assert rtp.printable?, rtp.errors.full_messages
  end

  test 'Missing fiscal year from Part B' do
    rtp = prep_empty_form
    rtp.update(supplier_address: 'Way St',
               supplier_city: 'Way Way',
               supplier_contact_person: 'Supplier Contact',
               supplier_name: 'Supplier',
               supplier_phone: '5555551212',
               supplier_postal_code: 'V0V 0V0',
               item_cost_1: '1,000',
               item_desp_1: 'iPad')

    assert !rtp.printable?, 'should be not printable'
    assert_equal ["can't be blank"], rtp.errors[:part_b_fiscal_year]
  end

  test 'Missing one item from Part B' do
    rtp = prep_empty_form
    rtp.update(supplier_address: 'Way St',
               supplier_city: 'Way Way',
               supplier_contact_person: 'Supplier Contact',
               supplier_name: 'Supplier',
               supplier_phone: '5555551212',
               supplier_postal_code: 'V0V 0V0',
               # item_cost_1: '1,000',
               item_desp_1: 'iPad',
               part_b_fiscal_year: '2016-2017')

    assert !rtp.printable?, 'should be not printable'
    assert_equal ["can't be blank"], rtp.errors[:item_cost_1]
    assert_equal 1, rtp.errors.size, rtp.errors.full_messages
  end

  test 'Missing one item from each section' do
    rtp = prep_empty_form
    rtp.update(supplier_address: 'Way St',
               supplier_city: 'Way Way',
               supplier_contact_person: 'Supplier Contact',
               supplier_name: 'Supplier',
               supplier_phone: '5555551212',
               #  supplier_postal_code: 'V0V 0V0',
               part_b_fiscal_year: '2016-2017',
               item_cost_1: '1,000',
               item_desp_1: 'iPad',
               agency_name: 'Disable Clinic',
               payment: 'provider',
               service_provider_postal_code: 'V0V 0V0',
               service_provider_address: 'Way St',
               service_provider_city: 'Way Way',
               service_provider_phone: '5555551212',
               service_provider_name: 'B Intervention',
               service_provider_service_1: 'Behaviour Intervention',
               service_provider_service_amount: '1,000',
               service_provider_service_end: '2017-02-28',
               #  service_provider_service_fee: '100',
               service_provider_service_hour: 'hour',
               service_provider_service_start: '2016-10-01'
              )

    assert !rtp.printable?, 'should be not printable'
    assert_equal 2, rtp.errors.size, rtp.errors.full_messages
    assert_equal ["can't be blank"], rtp.errors[:service_provider_service_fee]
    assert_equal ["can't be blank"], rtp.errors[:supplier_postal_code]
  end

  test 'Missing one item from part A section' do
    rtp = prep_empty_form
    rtp.update(supplier_address: 'Way St',
               supplier_city: 'Way Way',
               supplier_contact_person: 'Supplier Contact',
               supplier_name: 'Supplier',
               supplier_phone: '5555551212',
               supplier_postal_code: 'V0V 0V0',
               item_cost_1: '1,000',
               item_desp_1: 'iPad',
               part_b_fiscal_year: '2016-2017',
               agency_name: 'Disable Clinic',
               payment: 'provider',
               service_provider_postal_code: 'V0V 0V0',
               service_provider_address: 'Way St',
               service_provider_city: 'Way Way',
               service_provider_phone: '5555551212',
               service_provider_name: 'B Intervention',
               #  service_provider_service_1: 'Behaviour Intervention',
               service_provider_service_amount: '1,000',
               service_provider_service_end: '2017-02-28',
               service_provider_service_fee: '100',
               service_provider_service_hour: 'hour',
               service_provider_service_start: '2016-10-01'
              )

    assert !rtp.printable?, 'should be not printable'
    assert_equal 1, rtp.errors.size, rtp.errors.full_messages
    assert_equal ["can't be blank"], rtp.errors[:service_provider_service_1]
  end

  test 'save with validation failure in postal_code' do
    rtp = prep_empty_form
    assert rtp.save_with_user, 'Initial save failed.'
    # pp rtp
    # pp rtp.funded_person
    # pp rtp.funded_person.user
    # pp rtp.funded_person.user.address
    # pp rtp.funded_person.user.postal_code
    rtp.funded_person.user.postal_code = 'VVV 000'
    rtp.service_provider_name = "Hey, here's a name"
    result_of_save = rtp.save_with_user
    # puts rtp.errors.full_messages
    rtp_from_db = Cf0925.find(rtp.id)
    # pp rtp.funded_person
    # pp rtp.funded_person.user
    # pp rtp.funded_person.user.address
    # pp rtp.funded_person.user.postal_code
    # rtp.funded_person.user.reload
    assert_not_equal 'VVV 000', rtp_from_db.funded_person.user.postal_code
    assert_not_equal "Hey, here's a name", rtp_from_db.service_provider_name
    assert !result_of_save, "RTP save worked when it shouldn't have"
  end

  test 'save with validation failure in home_phone_number' do
    rtp = prep_empty_form
    assert rtp.save_with_user, 'Initial save failed.'
    # pp rtp
    rtp.funded_person.user.home_phone_number = '66677788889'
    rtp.service_provider_name = "Hey, here's a name"
    assert !rtp.save_with_user, 'Save succeded when it should have failed'
    rtp_from_db = Cf0925.find(rtp.id)
    assert_equal '5555551212', rtp_from_db.funded_person.user.home_phone_number
    assert_not_equal "Hey, here's a name", rtp_from_db.service_provider_name
  end

  test 'change postal code and update user' do
    rtp = prep_empty_form
    rtp.funded_person.user.postal_code = 'V0V 0V1'
    assert rtp.save_with_user
    rtp.reload
    assert_equal 'V0V0V1', rtp.funded_person.user.postal_code
  end

  test 'change phone number and update user' do
    rtp = prep_empty_form
    rtp.funded_person.user.home_phone_number = '5555551213'
    assert rtp.save_with_user
    rtp.reload
    assert_equal '5555551213', rtp.funded_person.user.home_phone_number
  end

  private

  def prep_empty_form
    user = User.new(email: 'empty_form@autism-funding.com',
                    password: 'aslk234jakl',
                    name_first: 'Empty',
                    name_last: 'Form')
    user.addresses.build(address_line_1: 'Empty St',
                         city: 'Sadville',
                         province_code: province_codes(:bc),
                         postal_code: 'V0V 0V0')
    user.phone_numbers.build(phone_type: 'Home', phone_number: '5555551212')
    child = user.funded_people.build(name_first: 'Empty',
                                     name_last: 'Form',
                                     birthdate: '2003-09-30',
                                     child_in_care_of_ministry: false)
    child.cf0925s.build
  end
end
