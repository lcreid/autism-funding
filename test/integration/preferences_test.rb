require 'test_helper'
require 'capybara/poltergeist'

class PreferencesTest < PoltergeistTest
  include TestSessionHelpers

  test 'collapsed and expanded accordion preferences' do
    fill_in_login(user = users(:dual_child_parent))
    assert_current_path root_path
    assert_content 'Sixteen Year Two-Kids'
    assert_content 'Four Year Two-Kids'
    last_child = user.funded_people.last
    assert_selector("#collapse-#{last_child.id}.in")

    puts "About to click name: #{last_child.my_name}"
    click_link(last_child.my_name)
    # The next couple of lines make sure this test script doesn't get
    # ahead of PhantomJS.
    assert_no_selector("#collapse-#{last_child.id}.collapsing")
    assert_no_selector("#collapse-#{last_child.id}.in")
    assert_current_path root_path

    click_link 'My Profile'
    assert_content 'My Funded Children'
    assert_current_path my_profile_index_path

    click_link 'My Home'
    assert_no_content 'My Funded Children'
    assert_content 'Sixteen Year Two-Kids'
    assert_current_path root_path
    puts 'Looking for collapsed panel.'
    # The next line is just to make sure we're synched up before looking
    # for the expanded panel.
    assert_selector("#collapse-#{last_child.id}")
    assert_no_selector("#collapse-#{last_child.id}.in")

    click_link(last_child.my_name)
    # The next line is just to make sure we're synched up before looking
    # for the expanded panel.
    assert_no_selector("#collapse-#{last_child.id}.collapsing")
    assert_selector("#collapse-#{last_child.id}.in")
    click_link 'My Profile'
    assert_content 'My Funded Children'
    assert_current_path my_profile_index_path

    click_link 'My Home'
    assert_current_path root_path
    assert_selector("#collapse-#{last_child.id}.in")
  end

  test 'fiscal year menu preferences' do
    fill_in_login(users(:years))
    assert_current_path root_path

    child_id = funded_people(:two_fiscal_years).id
    two_year_kid = "year_#{child_id}"

    assert_select two_year_kid, selected: '2016-2017'
    select '2015-2016', from: two_year_kid
    # This next line helps Capybara get back in sync with the extra submit
    # that the page does when you select from the fiscal year drop-down.
    assert_content 'Joe 2015'
    assert_no_select two_year_kid, selected: '2016-2017'
    assert_select two_year_kid, selected: '2015-2016'

    # puts 'Going to My Profile'
    # puts page.body
    # assert_link 'My Profile'
    click_link 'My Profile'
    # puts find("a[href='/my_profile/index']").inspect
    # find("a[href='/my_profile/index']").click
    # visit my_profile_index_path
    assert_content 'My Funded Children'
    assert_current_path my_profile_index_path
    # puts 'Going back to My Home'
    click_link 'My Home'
    # visit root_path
    assert_current_path root_path

    # puts find("##{two_year_kid}").inspect
    assert_select two_year_kid, selected: '2015-2016'
    assert_select two_year_kid, selected: '2016-2017'
  end

  test 'BC reminder dismissed' do
    skip 'Remember state of reminder for BC residents'
  end
end
