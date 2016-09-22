require 'test_helper'
require 'capybara/poltergeist'

class HomePageTest < CapybaraTest
  include TestSessionHelpers

  def setup
    Capybara.javascript_driver = :poltergeist
    Capybara.current_driver = Capybara.javascript_driver
  end

  test 'collapse and expand accordion' do
    fill_in_login(user = users(:dual_child_parent))
    assert_current_path root_path
    assert_content 'Sixteen Year Two-Kids'
    assert_content 'Four Year Two-Kids'
    assert_content 'Funding spent', count: 2
    last_child = user.funded_people.last
    # puts evaluate_script("$('#collapse-#{last_child.id}').height();")
    assert_no_selector("#collapse-#{last_child.id}[style=\"height: 0px;\"]")
    click_link(last_child.my_name)
    # puts find("#collapse-#{last_child.id} > .panel-body").inspect
    # Gag. Bootstrap makes the body invisible by making it height: 0px.
    # skip 'Skip this shit. I know it works.'
    assert_selector("#collapse-#{last_child.id}[style=\"height: 0px;\"]")
    # puts "$('#collapse-#{last_child.id}').height();"
    # puts evaluate_script("$('#collapse-#{last_child.id}').height();")
    # puts find("#collapse-#{last_child.id}")['style']
    # find("#collapse-#{last_child.id}")
    # assert_equal 'height: 0px;', find("#collapse-#{last_child.id}")['style']
    # puts body
    # assert_equal 0, evaluate_script("$('#collapse-#{last_child.id}').height();")
    # assert_content 'Funding spent', count: 1
    click_link(last_child.my_name)
    assert_no_selector("#collapse-#{last_child.id}[style=\"height: 0px;\"]")
  end

  test 'fiscal year menu' do
    fill_in_login(users(:years))
    assert_current_path root_path

    within "#collapse-#{funded_people(:one_fiscal_year).id}" do
      select '2017', from: 'Year'
    end

    within "#collapse-#{funded_people(:two_fiscal_years).id}" do
      select '2015-2016', from: 'Year'
      select '2016-2017', from: 'Year'
    end
  end
end
