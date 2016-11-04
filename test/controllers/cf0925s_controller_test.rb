require 'test_helper'

class Cf0925sControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  def setup
    log_in
    ############################################################################
    ## TODO Test should be modified to take into account of the age of the
    ##      Funded Person.  Presently, form creation methods do not validate the
    ##      age of the Funded Person, so this is not an issue as yet
    ############################################################################

    @funded_person = FundedPerson.create!(birthdate: '2010-06-14',
                                          name_first: 'first',
                                          name_last: 'last',
                                          user: controller.current_user)

    @form_field_values = {
      'funded_person_attributes' => {
        'id' => @funded_person.id,
        'user_attributes' => {
          # 'id' => @funded_person.user.id,
          'name_first' => 'parent_first_name',
          'name_middle' => 'parent_middle_name',
          'name_last' => 'parent_last_name',
          'phone_numbers_attributes' => {
            '0' => {
              'id' => @funded_person.user.my_home_phone.id,
              'phone_number' => '8888888888',
              'phone_type' => 'Home'
            },
            '1' => {
              'id' => @funded_person.user.my_work_phone.id,
              'phone_number' => '7777777777',
              'phone_type' => 'Work',
              'phone_extension' => ''
            }
          },
          'addresses_attributes' => {
            '0' => {
              'id' => @funded_person.user.my_address.id,
              'address_line_1' => 'parent_address',
              'city' => 'parent_city',
              'postal_code' => 'A0A 0A0'
            }
          }
        }
      },
      agency_name: 'agency_name',
      child_dob: '2002-05-14',
      child_first_name: 'child_first_name',
      child_last_name: 'child_last_name',
      child_middle_name: 'child_middle_name',
      child_in_care_of_ministry: false,
      item_cost_1: 10,
      item_cost_2: 20,
      item_cost_3: 30,
      item_desp_1: 'item_desp_1',
      item_desp_2: 'item_desp_2',
      item_desp_3: 'item_desp_3',
      payment: 'Provider',
      service_provider_postal_code: 'service_provider_postal_code',
      service_provider_address: 'service_provider_address',
      service_provider_city: 'service_provider_city',
      service_provider_phone: 'service_provider_phone',
      service_provider_name: 'service_provider_name',
      service_provider_service_1: 'service_provider_service_1',
      service_provider_service_2: 'service_provider_service_2',
      service_provider_service_3: 'service_provider_service_3',
      service_provider_service_amount: 2000,
      service_provider_service_end: '2017-05-31',
      service_provider_service_fee: 150,
      service_provider_service_hour: 'service_provider_service_hour',
      service_provider_service_start: '2016-06-01',
      supplier_address: 'supplier_address',
      supplier_city: 'supplier_city',
      supplier_contact_person: 'supplier_contact_person',
      supplier_name: 'supplier_name',
      supplier_phone: 'supplier_phone',
      supplier_postal_code: 'supplier_postal_code',
      form_id: forms(:cf0925).id,
      funded_person_id: @funded_person.id
    }
  end

  test 'should get index' do
    get funded_person_cf0925s_path(@funded_person)
    assert_response :success
  end

  test 'Create a BC request to pay' do
    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person), params: {
        cf0925: {
          'funded_person_attributes' => {
            'id' => @funded_person.id,
            'user_attributes' => {
              # 'id' => @funded_person.user.id,
              'name_first' => 'parent_first_name',
              'name_middle' => 'parent_middle_name',
              'name_last' => 'parent_last_name',
              'phone_numbers_attributes' => {
                '0' => {
                  'id' => @funded_person.user.my_home_phone.id,
                  'phone_number' => '8888888887',
                  'phone_type' => 'Home'
                },
                '1' => {
                  'id' => @funded_person.user.my_work_phone.id,
                  'phone_number' => '7777777778',
                  'phone_type' => 'Work',
                  'phone_extension' => ''
                }
              },
              'addresses_attributes' => {
                '0' => {
                  'id' => @funded_person.user.my_address.id,
                  'address_line_1' => 'parent_address',
                  'city' => 'parent_city',
                  'postal_code' => 'A0A 0A0'
                }
              }
            }
          },
          child_in_care_of_ministry: false,
          item_cost_1: 10,
          item_cost_2: 20,
          item_cost_3: 30,
          item_desp_1: 'item_desp_1',
          item_desp_2: 'item_desp_2',
          item_desp_3: 'item_desp_3',
          payment: 'Provider',
          service_provider_postal_code: 'service_provider_postal_code',
          service_provider_address: 'service_provider_address',
          service_provider_city: 'service_provider_city',
          service_provider_phone: 'service_provider_phone',
          service_provider_name: 'service_provider_name',
          service_provider_service_1: 'service_provider_service_1',
          service_provider_service_2: 'service_provider_service_2',
          service_provider_service_3: 'service_provider_service_3',
          service_provider_service_amount: 2000,
          service_provider_service_end: '2017-05-31',
          service_provider_service_fee: 150,
          service_provider_service_hour: 'service_provider_service_hour',
          service_provider_service_start: '2016-06-01',
          supplier_address: 'supplier_address',
          supplier_city: 'supplier_city',
          supplier_contact_person: 'supplier_contact_person',
          supplier_name: 'supplier_name',
          supplier_phone: 'supplier_phone',
          supplier_postal_code: 'supplier_postal_code',
          form_id: forms(:cf0925).id,
          funded_person_id: @funded_person.id
        }
      }
    end

    # After form creation, the user should have 2 phone numbers and 1 addresses
    @funded_person.reload
    assert_equal 1, @funded_person.user.addresses.size, "User should have exactly 1 associated address after form creation"
    assert_equal 2, @funded_person.user.phone_numbers.size, "User should have exactly 2 associated phone numbers after form creation"


    # FundedPerson.all.each { |funded_person| puts "#{funded_person.name_last}: #{funded_person.my_dob}" }
    # Cf0925.all.each { |rtp| puts "#{rtp.funded_person.name_last}: #{rtp.funded_person.my_dob}" }
    assert_not_nil(cf0925 = Cf0925.find_by(child_dob: '2010-06-14'))
    assert_redirected_to home_index_path
  end

  test 'CF_0925 child between 6 and 18' do
    ## - debug statement -- show_user_status " (Line: #{__LINE__})"

    # get new_funded_person_cf0925_path(@funded_person)
    # assert_response :success
    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: @form_field_values }
    end

    # After form creation, the user should have 2 phone numbers and 1 addresses
    @funded_person.reload
    assert_equal 1, @funded_person.user.addresses.size, "User should have exactly 1 associated address after form creation"
    assert_equal 2, @funded_person.user.phone_numbers.size, "User should have exactly 2 associated phone numbers after form creation"

    assert_response :redirect
    follow_redirect!

    assert_response :success

    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_select '#cf0925_service_provider_service_start[value=?]',
                  @form_field_values[:service_provider_service_start]
  end

  test 'CF_0925 start date after end date' do
    # get new_funded_person_cf0925_path(@funded_person)
    # assert_response :success
    # assert_equal path, new_funded_person_cf0925_path(@funded_person)

    # Make a bad date.
    bad_date_params = @form_field_values.merge(service_provider_service_end: '2016-05-31')

    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_date_params }
    end


    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_redirected_to home_index_path
    follow_redirect!
    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_match(/must be after start date/, body)
  end

  test 'CF_0925 start date must exist' do
    # get new_funded_person_cf0925_path(@funded_person)
    # assert_response :success

    # Make a bad date.
    bad_date_params = @form_field_values.merge(service_provider_service_start: '')

    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_date_params }
    end

    assert_redirected_to home_index_path
    follow_redirect!
    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_match(/can&#39;t be blank/, body)
  end

  test 'Parent last name must exist' do
    # get new_funded_person_cf0925_path(@funded_person)
    # assert_response :success

    # Make a bad date.
    bad_name_params = @form_field_values # .merge(service_provider_service_end: '')
    bad_name_params['funded_person_attributes']['user_attributes']['name_last'] = ''

    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_name_params }
    end

    assert_redirected_to home_index_path
    follow_redirect!
    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_select '#cf0925_funded_person_attributes_user_attributes_name_last'\
                  ' ~ span.help-block',
                  "can't be blank"
  end

  test 'CF_0925 end date must exist' do
    # get new_funded_person_cf0925_path(@funded_person)
    # assert_response :success

    # Make a bad date.
    bad_date_params = @form_field_values.merge(service_provider_service_end: '')

    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_date_params }
    end

    # skip "I don't know how to show status of invalid, but saved, record"
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_redirected_to home_index_path
    follow_redirect!
    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_match(/can&#39;t be blank/, body)
  end

  test 'CF_0925 agency checkbox disabled if no agency' do
    skip 'Test for agency checkbox disabled.'
  end

  test 'CF_0925 agency checkbox required' do
    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: {
             cf0925: @form_field_values.reject { |k, _| k == :payment }
           }
    end

    # skip "I don't know how to show status of invalid, but saved, record"
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_redirected_to home_index_path
    follow_redirect!
    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_match(/please choose either service provider or agency/, body)
  end

  test 'Address must exist' do
    # get new_funded_person_cf0925_path(@funded_person)
    # assert_response :success

    bad_address_params = @form_field_values
    bad_address_params['funded_person_attributes']['user_attributes']['addresses_attributes']['0']['address_line_1'] = ''
    bad_address_params['funded_person_attributes']['user_attributes']['addresses_attributes']['0']['city'] = ''
    bad_address_params['funded_person_attributes']['user_attributes']['addresses_attributes']['0']['postal_code'] = ''

    # pp bad_address_params
    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_address_params }
    end

    assert_redirected_to home_index_path
    follow_redirect!
    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_select '#cf0925_funded_person_attributes_user_attributes_addresses_attributes_0_address_line_1 ~ span.help-block',
                  "can't be blank"
    assert_select '#cf0925_funded_person_attributes_user_attributes_addresses_attributes_0_city ~ span.help-block',
                  "can't be blank"
    assert_select '#cf0925_funded_person_attributes_user_attributes_addresses_attributes_0_postal_code ~ span.help-block',
                  "can't be blank"
    # puts body
    # assert_select '.alert', "Address line 1 can't be blank"
    # assert_select '.alert', "City can't be blank"
    # assert_select '.alert', "Postal code can't be blank"
  end

  test 'Phone number must exist and be valid' do
    # get new_funded_person_cf0925_path(@funded_person)
    # assert_response :success

    bad_phone_params = @form_field_values
    bad_phone_params['funded_person_attributes']['user_attributes']['phone_numbers_attributes']['0']['phone_number'] = ''
    bad_phone_params['funded_person_attributes']['user_attributes']['phone_numbers_attributes']['1']['phone_number'] = ''

    # pp bad_phone_params
    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_phone_params }
    end

    assert_redirected_to home_index_path
    follow_redirect!
    get edit_cf0925_path(@funded_person.cf0925s.last)
    assert_select '.alert', 'Phone numbers must provide at least one phone number'
  end
end
