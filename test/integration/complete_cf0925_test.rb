require 'test_helper'

class CompleteCf0925Test < CapybaraTest
  include TestSessionHelpers

  fixtures :forms
  fixtures :funded_people

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
      supplier_postal_code: 'N0N 0N0'
    }.each do |k, v|
      fill_in 'cf0925_' + k.to_s, with: v
    end
    choose 'cf0925_payment_choice2'

    assert_difference 'Cf0925.count' do
      click_button 'Save'
    end
    assert_equal 200, status_code
    assert(rtp = Cf0925.find_by(agency_name: 'autofill user and child'),
           'Could not find record')
    assert_equal cf0925_path(rtp), current_path
    assert_link 'Print'
    skip 'Need JavaScript to disable above link'
  end

  test 'RTP for dual-child parent' do
    user = users(:dual_child_parent)

    fill_in_login user
    assert_title(Globals.site_name + ' All Children')

    assert_selector '.child .name', count: 2 do |child|
      assert_equal 'Sixteen Old Two-Kids', child[0].text
      assert_equal 'Four Old Two-Kids', child[1].text
    end
    within '.child:first' do
      click_link 'New Request to Pay'
    end

    assert_content 'Section 1 Parent/Guardian Information'

    # assert_field works on the label, so if you don't have a label, it won't
    # work. It also doesn't use the ID, but rather the "for=" attribute.
    # This was for when the fields were fillable. We decided you have to go
    # back to the profile page to do that.
    # FIXME: Change word order in label.
    assert_field 'Name Last', with: 'Two-Kids'
    assert_field 'Name First', with: 'I'
    # assert_field 'cf0925_child_first_name', with: 'Sixteen'
    # assert_selector '#parent_last_name', text: 'Two-Kids'
    # assert_selector '#parent_first_name', text: 'I'
    assert_selector '#child_first_name', text: 'Sixteen'
  end

  test 'Change parent info' do
    create_a_cf0925
  end

  test 'Edit an existing CF0925' do
    create_a_cf0925

    click_link 'Edit'
    new_city = 'Vernon'
    within '.parent-address-fields' do
      fill_in 'City', with: new_city
    end
    assert_no_difference 'Cf0925.count' do
      assert_no_difference 'FundedPerson.count' do
        assert_no_difference 'User.count' do
          assert_no_difference 'Address.count' do
            assert_no_difference 'PhoneNumber.count' do
              click_button 'Save'
            end
          end
        end
      end
    end

    assert Address.find_by(city: new_city), "City in address not #{new_city}"
  end

  private

  def create_a_cf0925
    address = '9999 Secondary St'
    middle_name = 'Charles'
    phone_number = '(999) 999-9999'

    fill_in_login(users(:forms))
    click_link 'New Request to Pay'
    assert_difference 'Cf0925.count' do
      assert_no_difference 'User.count' do
        # assert_difference 'PhoneNumber.count' do
        # FIXME: Label should be Middle Name even if field is Name Middle
        fill_in 'Name Middle', with: middle_name
        within '.parent-test' do
          fill_in 'Address', with: address
          # puts 'Phones: ' + all(:fillable_field, 'Phone').inspect
          # all(:fillable_field, 'Home Phone').each do |e|
          #   puts e[:id]
          # end
          fill_in 'Home Phone', with: phone_number
        end
        # I shouldn't really need the following.
        fill_in 'cf0925_service_provider_service_start', with: '2016-08-01'
        fill_in 'cf0925_service_provider_service_end', with: '2016-09-30'
        choose 'cf0925_payment_choice1'
        click_button 'Save'
        # end
      end
    end
    # puts "Middle name from user: #{user.name_middle}"
    # user.reload
    # puts "Middle name from user: #{user.name_middle}"
    assert PhoneNumber.find_by(phone_number: '9999999999'),
           'PhoneNumber not updated'
    assert Cf0925.find_by(home_phone: phone_number),
           'Phone in RTP not updated'
    assert User.find_by(name_middle: middle_name), 'Parent not updated'
    assert Cf0925.find_by(service_provider_service_start: '2016-08-01'),
           'Start date in RTP not updated'
    assert Cf0925.find_by(parent_middle_name: middle_name), 'Parent middle name in RTP not updated'
    assert Address.find_by(address_line_1: address), 'Address not updated'
    assert Cf0925.find_by(parent_address: address), 'Address in RTP not updated'
  end
end
