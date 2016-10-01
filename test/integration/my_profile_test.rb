require 'test_helper'

class MyProfileTest < CapybaraTest
  test 'create a user and fill in the user profile (but not child)' do
    password = 'boson-detector'

    visit '/'
    assert_equal '/welcome/index', current_path
    # There are many Sign Up links on the page, so do within
    within '.navbar' do
      click_link 'Sign Up'
    end

    email = 'myprofiletest@weenhanceit.com'
    assert_equal '/users/sign_up', current_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    assert_difference 'User.count' do
      click_button 'Sign up'
    end

    # We pre-create empty records so this test will fail for a brand new user.
    # assert_equal 0, User.find_by(email: email).addresses.size

    assert_equal '/', current_path
    within 'nav' do
      click_link 'My Profile'
    end
    assert_equal '/my_profile/index', current_path
    click_link 'edit'

    assert_equal '/my_profile/edit', current_path
    address_hash = {
      address_line_1: '1234567 Main St',
      city: 'Kamloops',
      province_code_id: (province = ProvinceCode.find_by(province_code: 'BC')).id
    }

    user_hash = {
      name_first: 'Furst',
      name_last: 'Laast'
    }

    # assert_difference 'PhoneNumber.count', 2 do
    # assert_difference 'Address.count' do
    assert_no_difference 'User.count' do
      fill_in 'user_name_first', with: user_hash[:name_first]
      fill_in 'user_name_last', with: user_hash[:name_last]
      fill_in 'address_address_line_1', with: address_hash[:address_line_1]
      fill_in 'address_city', with: address_hash[:city]
      select province.province_name, from: 'address_province_code_id'
      fill_in 'home_phone_number_phone_number', with: '5555555555'
      fill_in 'work_phone_number_phone_number', with: '6666666666'
      click_link_or_button 'Update User'
    end
    # end
    # end

    assert_equal '/my_profile/index', current_path
    user = User.find_by(name_last: user_hash[:name_last])
    assert_equal user_hash[:name_first], user.name_first
    assert_equal user_hash[:name_last], user.name_last
    assert_equal address_hash[:address_line_1], user.my_address.address_line_1
    assert_equal address_hash[:city], user.my_address.city
    assert_equal address_hash[:province_code_id], user.my_address.province_code_id
    assert_equal '(555) 555-5555', user.my_home_phone.full_number
    assert_equal '(666) 666-6666', user.my_work_phone.full_number
  end
end
