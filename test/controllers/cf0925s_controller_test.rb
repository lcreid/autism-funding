require 'test_helper'

class Cf0925sControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  def setup
    log_in
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
              # 'user_id' => @funded_person.user.id,
              'phone_number' => '8888888888',
              'phone_type' => 'Home'
            },
            '1' => {
              # 'user_id' => @funded_person.user.id,
              'phone_number' => '7777777777',
              'phone_type' => 'Work',
              'phone_extension' => ''
            }
          },
          'addresses_attributes' => {
            '0' => {
              # 'user_id' => @funded_person.user.id,
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
                  # 'user_id' => @funded_person.user.id,
                  'phone_number' => '8888888888',
                  'phone_type' => 'Home'
                },
                '1' => {
                  # 'user_id' => @funded_person.user.id,
                  'phone_number' => '7777777777',
                  'phone_type' => 'Work',
                  'phone_extension' => ''
                }
              },
              'addresses_attributes' => {
                '0' => {
                  # 'user_id' => @funded_person.user.id,
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

    # FundedPerson.all.each { |funded_person| puts "#{funded_person.name_last}: #{funded_person.my_dob}" }
    # Cf0925.all.each { |rtp| puts "#{rtp.funded_person.name_last}: #{rtp.funded_person.my_dob}" }
    assert_not_nil(cf0925 = Cf0925.find_by(child_dob: '2010-06-14'))
    assert_redirected_to cf0925_path(cf0925)
  end

  test 'CF_0925 child between 6 and 18' do
    get new_funded_person_cf0925_path(@funded_person)
    assert_response :success
    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: @form_field_values }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :success

    assert_select '#service_provider_service_start',
                  @form_field_values[:service_provider_service_start]
  end

  test 'CF_0925 start date after end date' do
    get new_funded_person_cf0925_path(@funded_person)
    assert_response :success

    # Make a bad date.
    bad_date_params = @form_field_values.merge(service_provider_service_end: '2016-05-31')

    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_date_params }
    end

    assert_response :redirect
    skip "I don't know how to show status of invalid, but saved, record"
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_equal funded_person_cf0925s_path(@funded_person), path
    assert_select '.error-explanation li', 1 do |error|
      assert_equal 'Service provider service end must be after start date',
                   error.text
    end
  end

  test 'CF_0925 start date must exist' do
    get new_funded_person_cf0925_path(@funded_person)
    assert_response :success

    # Make a bad date.
    bad_date_params = @form_field_values.merge(service_provider_service_start: '')

    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_date_params }
    end

    assert_response :redirect
    skip "I don't know how to show status of invalid, but saved, record"
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_equal funded_person_cf0925s_path(@funded_person), path
    assert_select '.error-explanation li', 1 do |error|
      assert_equal "Service provider service start can't be blank",
                   error.text
    end
  end

  test 'CF_0925 end date must exist' do
    get new_funded_person_cf0925_path(@funded_person)
    assert_response :success

    # Make a bad date.
    bad_date_params = @form_field_values.merge(service_provider_service_end: '')

    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_date_params }
    end

    assert_response :redirect
    skip "I don't know how to show status of invalid, but saved, record"
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_equal funded_person_cf0925s_path(@funded_person), path
    assert_select '.error-explanation li', 1 do |error|
      assert_equal "Service provider service end can't be blank",
                   error.text
    end
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

    assert_response :redirect
    skip "I don't know how to show status of invalid, but saved, record"
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_equal funded_person_cf0925s_path(@funded_person), path
    assert_select '.error-explanation li', 1 do |error|
      assert_equal 'Payment please choose either service provider or agency',
                   error.text
    end
  end
end
