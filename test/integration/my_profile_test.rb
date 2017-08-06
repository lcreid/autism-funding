require 'test_helper'
require 'helpers/my_profile_test_helpers.rb'
class MyProfileTest < MyProfileTestHelper::MyProfileTestPage
  testName = '01 Check User can be created and saved'
  test testName do
    test_email = 'a_guy@weenhanceit.com'
    test_password = 'very_secret'

    # a) Create new user (sign up)
    visit '/'
    assert_equal '/welcome/index', current_path, '01.a_i - Check Unregistered users wind up on welcome page'

    visit '/my_profile/edit'
    assert_equal '/welcome/index', current_path, '01.a_ii - Check Unregistered users wind up on welcome page'

    # There are many Sign Up links on the page, so do within
    within '.navbar' do
      click_link 'Sign Up'
    end
    assert_equal '/users/sign_up', current_path, '01.a_iii - Should be on sign_up page'

    fill_in 'Email', with: test_email
    fill_in 'Password', with: test_password
    fill_in 'Password confirmation', with: test_password
    assert_difference 'User.count', 1, '01.a_iv - Number of Users did not increase by 1' do
      click_button 'Sign up'
    end

    # b) Log Out
    click_link 'Log out'
    assert_equal '/welcome/index', current_path, '01.b - Check Logged out users wind up on welcome page'

    # c) Log Back In
    within '.navbar' do
      click_link 'Log in'
    end
    assert_equal '/users/sign_in', current_path, '01.c - Should be on Log In Page'
    fill_in 'Email', with: test_email
    fill_in 'Password', with: test_password
    click_button 'Log in'

    # d) Check that we wind up on my profile, with correct notifications
    assert_equal '/my_profile/edit', current_path, '01.d.i - Brand New Users should be sent to My Profile'

    # e) check the notifications for a blank user Profile
    check_notifications(__LINE__, '01.e', true, true)

    fill_in_form_items
    click_link_or_button 'Update User'
    assert_equal '/my_profile/edit', current_path, '01.f - should be on my_profile_edit - no children defined'
    check_form(__LINE__, '01.g')
    check_notifications(__LINE__, '01.h', false, true)

    set_value(:work_phone_number, :valid, '')
    click_link_or_button 'Update User'
    assert_equal '/my_profile/edit', current_path, '01.i - should remain on my_profile_edit - no children defined'
    check_form(__LINE__, '01.j')
    check_notifications(__LINE__, '01.k', false, true)

    set_invalid :work_phone_number
    #    fill_in_form_items
    click_link_or_button 'Update User'
    assert_equal '/my_profile/edit', current_path, '01.l - should remain on my_profile_edit - no children defined'
    check_form(__LINE__, '01.m')
    check_notifications(__LINE__, '01.n', false, true)

    set_value(:work_phone_number, :valid, '')
    add_child(:valid)

    click_link_or_button 'Update User'
    # check_notifications(__LINE__, '01.n', false, true)
    # check_form(__LINE__, 'phil')
    # puts body
    assert_equal '/', current_path, '01.g.o - Everything was kosher - should be on My Home page'

    # assert_equal '/my_profile/edit', current_path, "01.g.i - Brand New Users should be sent to My Profile"
    # check_form(__LINE__, '01.g')
  end
end #--- class MyProfileTest ---------------------
