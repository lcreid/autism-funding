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
    Rails.logger.debug { "The last child is #{last_child.inspect}" }
    assert_selector("#collapse-#{last_child.id}.in")

    Rails.logger.debug { "About to click name: #{last_child.my_name}" }
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
    assert_content 'Four Year Two-Kids'
    assert_current_path root_path
    Rails.logger.debug { 'Looking for collapsed panel.' }
    # The next line is just to make sure we're synched up before looking
    # for the expanded panel.
    assert_selector("#collapse-#{last_child.id}", visible: false)
    assert_no_selector("#collapse-#{last_child.id}.in")

    # Ugh. Not supposed to do this, but what choice do I have?
    sleep(5)
    click_link(last_child.my_name)
    Rails.logger.debug { 'Just clicked link to show panel.' }
    # The next line is just to make sure we're synched up before looking
    # for the expanded panel.
    assert_content 'Four Year Two-Kids'
    assert_selector("#collapse-#{last_child.id}.in")

    click_link 'My Profile'
    assert_content 'My Funded Children'
    assert_current_path my_profile_index_path

    Rails.logger.debug { 'Going back to home.' }
    click_link 'My Home'
    assert_content 'Four Year Two-Kids'
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

    # Rails.logger.debug { 'Going to My Profile' }
    # Rails.logger.debug { page.body }
    # assert_link 'My Profile'
    click_link 'My Profile'
    # Rails.logger.debug { find("a[href='/my_profile/index']").inspect }
    # find("a[href='/my_profile/index']").click
    # visit my_profile_index_path
    assert_content 'My Funded Children'
    assert_current_path my_profile_index_path
    # Rails.logger.debug { 'Going back to My Home' }
    click_link 'My Home'
    # visit root_path
    assert_current_path root_path

    # Rails.logger.debug { find("##{two_year_kid}").inspect }
    assert_select two_year_kid, selected: '2015-2016'
  end

  test 'BC reminder dismissed' do
    skip 'Remember state of reminder for BC residents'
  end
end
