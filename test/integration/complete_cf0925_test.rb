require 'test_helper'

class CompleteCf0925Test < ActionDispatch::IntegrationTest
  test 'CF_0925 child between 6 and 18' do
    form_field_values = {
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
      payment: 150,
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
      work_phone: 'work_phone'
    }

    get new_cf0925_path
    assert_response :success
    assert_difference('Cf0925.count') do
      post '/cf0925s', params: { cf0925: form_field_values }
    end

    assert_response :redirect
    follow_redirect!
    assert_response :success

    assert_select 'p#service_provider_service_start .value',
                  form_field_values[:service_provider_service_start]
  end

  test 'CF_0925 start date after end date' do
    skip
  end

  test 'CF_0925 no agency auto-fill checkbox' do
    skip
  end

  test 'CF_0925 agency checkbox required' do
    skip
  end

  test 'CF_0925 autofill from user' do
    skip
  end

  test 'CF_0925 autofill from child' do
    skip
  end
end
