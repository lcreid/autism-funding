require 'test_helper'

class Cf0925sControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  def setup
    log_in
    @funded_person = FundedPerson.create!(birthdate: '2010-06-14',
                                          name_first: 'first',
                                          name_last: 'last',
                                          user: controller.current_user)
  end

  test 'should get index' do
    get funded_person_cf0925s_path(@funded_person)
    assert_response :success
  end

  test 'Create a BC request to pay' do
    assert_difference('Cf0925.count') do
      post funded_person_cf0925s_path(@funded_person), params: {
        cf0925: {
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
          work_phone: 'work_phone',
          form_id: forms(:cf0925).id,
          funded_person_id: funded_people(:cf0925).id
        }
      }
    end

    assert_not_nil(cf0925 = Cf0925.find_by(child_dob: '2002-05-14'))
    assert_redirected_to cf0925_path(cf0925)
  end
end
