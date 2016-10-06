require 'test_helper'
require 'capybara/poltergeist'

class HomePageTest < PoltergeistTest
  include TestSessionHelpers

  test 'collapse and expand accordion' do
    fill_in_login(user = users(:dual_child_parent))
    assert_current_path root_path
    assert_content 'Sixteen Year Two-Kids'
    assert_content 'Four Year Two-Kids'
    last_child = user.funded_people.last
    # puts evaluate_script("$('#collapse-#{last_child.id}').height();")
    assert_no_selector("#collapse-#{last_child.id}[style=\"height: 0px;\"]")
    click_link(last_child.my_name)
    # puts find("#collapse-#{last_child.id} > .panel-body").inspect
    # Gag. Bootstrap makes the body invisible by making its height: 0px.
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

    within "#collapse-#{child_id = funded_people(:one_fiscal_year).id}" do
      select '2017', from: "year_#{child_id}"
    end

    within "#collapse-#{child_id = funded_people(:two_fiscal_years).id}" do
      select '2015-2016', from: "year_#{child_id}"
      select '2016-2017', from: "year_#{child_id}"
    end
  end

  test 'go to all invoices' do
    fill_in_login(users(:years))
    within "#collapse-#{child = funded_people(:two_fiscal_years).id}" do
      click_link 'All Invoices'
    end
    assert_current_path funded_person_invoices_path(child)
  end

  test 'status panel' do
    fill_in_login(users(:years))
    within "#collapse-#{child_id = funded_people(:two_fiscal_years).id}" do
      # puts body
      assert_selector '.test-spent-funds', text: /\$0.00/
      assert_selector '.test-committed-funds', text: /\$3,000.00/
      assert_selector '.test-remaining-funds', text: /\$3,000.00/
      assert_selector '.test-spent-out-of-pocket', text: /\$0.00/
      assert_selector '.test-allowable-funds-for-year', text: /\$6,000.00/

      select '2015-2016', from: "year_#{child_id}"

      assert_selector '.test-spent-funds', text: /\$200.00/
      assert_selector '.test-committed-funds', text: /\$2,500.00/
      assert_selector '.test-remaining-funds', text: /\$3,500.00/
      assert_selector '.test-spent-out-of-pocket', text: /\$0.00/
      assert_selector '.test-allowable-funds-for-year', text: /\$6,000.00/
    end
  end
end
