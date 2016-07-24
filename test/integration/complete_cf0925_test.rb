require 'test_helper'

class CompleteCf0925Test < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  fixtures :forms

  def setup
    @form_field_values = {
      agency_name: 'agency_name',
      child_dob: '2002-05-14',
      child_first_name: 'child_first_name',
      child_last_name: 'child_last_name',
      child_middle_name: 'child_middle_name',
      child_in_care_of_ministry: false,
      home_phone: 'home_phone',
      item_cost_1: 10,
      item_cost_2: 20,
      item_cost_3: 30,
      item_desp_1: 'item_desp_1',
      item_desp_2: 'item_desp_2',
      item_desp_3: 'item_desp_3',
      parent_address: 'parent_address',
      parent_city: 'parent_city',
      parent_first_name: 'parent_first_name',
      parent_last_name: 'parent_last_name',
      parent_middle_name: 'parent_middle_name',
      parent_postal_code: 'parent_postal_code',
      payment: 'Choice2',
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
      work_phone: 'work_phone',
      form_id: forms(:cf0925).id,
      funded_person_id: (@funded_person = funded_people(:cf0925)).id
    }
  end

  test 'CF_0925 child between 6 and 18' do
    log_in
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
    log_in
    get new_funded_person_cf0925_path(@funded_person)
    assert_response :success

    # Make a bad date.
    bad_date_params = @form_field_values.merge(service_provider_service_end: '2016-05-31')

    assert_no_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: { cf0925: bad_date_params }
    end

    assert_response :success
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_equal funded_person_cf0925s_path(@funded_person), path
    assert_select '.error-explanation li', 1 do |error|
      assert_equal 'Service provider service end must be after start date',
                   error.text
    end
  end

  test 'CF_0925 agency checkbox disabled if no agency' do
    skip 'Test for agency checkbox disabled.'
  end

  test 'CF_0925 agency checkbox required' do
    log_in
    assert_no_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person),
           params: {
             cf0925: @form_field_values.reject { |k, _| k == :payment }
           }
    end

    assert_response :success
    # The next assert is like it is because the render in the controller
    # is rendering the new view, but from the create action in the controller,
    # so the path is the path for create, which is like the post above.
    assert_equal funded_person_cf0925s_path(@funded_person), path
    assert_select '.error-explanation li', 1 do |error|
      assert_equal 'Payment please choose either service provider or agency',
                   error.text
    end
  end

  test 'CF_0925 autofill from user and child' do
    fill_in_login
    # TODO: Make this follow links when we nail down the UI.
    visit new_funded_person_cf0925_path(@funded_person)

    {
      agency_name: 'autofill user and child',
      item_cost_1: 10,
      item_cost_2: 20,
      item_cost_3: 30,
      item_desp_1: 'Tablet',
      item_desp_2: 'Phone',
      item_desp_3: 'Notebook',
      service_provider_postal_code: 'N1N 1N1',
      service_provider_address: '22222 Main St.',
      service_provider_city: 'Vancouver',
      service_provider_phone: '555-555-2345',
      service_provider_name: 'Joe B. Consultant',
      service_provider_service_1: 'Behaviour consulting',
      service_provider_service_amount: 2000,
      service_provider_service_end: '2017-05-31',
      service_provider_service_fee: 150,
      service_provider_service_hour: 'hour',
      service_provider_service_start: '2016-06-01',
      supplier_address: '11111 Main St.',
      supplier_city: 'Vancouver',
      supplier_name: 'ABBA Learning',
      supplier_phone: '555-555-1234',
      supplier_postal_code: 'N0N 0N0',
      work_phone: '555-555-5555'
    }.each do |k, v|
      fill_in 'cf0925_' + k.to_s, with: v
    end
    choose 'cf0925_payment_choice2'

    assert_difference 'Cf0925.count' do
      click_button 'Create Cf0925'
    end
    assert_equal 200, status_code
    assert(rtp = Cf0925.find_by(agency_name: 'autofill user and child'),
           'Could not find record')
    assert_equal cf0925_path(rtp), current_path
    assert page.has_link?('Print')
    skip 'Need JavaScript to disable above link'
  end
end
