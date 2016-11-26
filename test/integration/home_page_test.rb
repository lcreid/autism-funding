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
    # Gag. Bootstrap makes the body invisible by making its height: 0px.
    assert_no_selector("#collapse-#{last_child.id}.in")
    click_link(last_child.my_name)
    assert_selector("#collapse-#{last_child.id}.in")
    click_link(last_child.my_name)
    assert_no_selector("#collapse-#{last_child.id}.in")
  end

  test 'fiscal year menu' do
    fill_in_login(users(:years))
    assert_current_path root_path

    one_year_child = funded_people(:one_fiscal_year)
    click_link one_year_child.my_name
    assert_selector("#collapse-#{one_year_child.id}.in")

    within "#collapse-#{one_year_child.id}" do
      drop_down = "year_#{one_year_child.id}"
      select '2017', from: drop_down
      assert_select drop_down, selected: '2017'
    end

    # I can't seem to find a way to force Capybara to just wait until the
    # reply from the year select is done.
    sleep 1

    two_year_child = funded_people(:two_fiscal_years)
    click_link two_year_child.my_name
    assert_no_selector("#collapse-#{one_year_child.id}.in")
    assert_selector("#collapse-#{two_year_child.id}.in")

    within "#collapse-#{two_year_child.id}" do
      select '2015-2016', from: "year_#{two_year_child.id}"
      select '2016-2017', from: "year_#{two_year_child.id}"
    end
  end

  test 'go to all invoices' do
    fill_in_login(users(:years))
    two_year_child = funded_people(:two_fiscal_years)
    click_link two_year_child.my_name
    within "#collapse-#{two_year_child.id}" do
      click_link 'All Invoices'
    end
    assert_current_path funded_person_invoices_path(two_year_child)
  end

  test 'status panel' do
    fill_in_login(users(:years))
    two_year_child = funded_people(:two_fiscal_years)
    click_link two_year_child.my_name
    assert_selector("#collapse-#{two_year_child.id}.in")

    within "#collapse-#{two_year_child.id}" do
      # puts body
      assert_selector '.test-spent-funds', text: /\$0.00/
      assert_selector '.test-committed-funds', text: /\$3,000.00/
      assert_selector '.test-remaining-funds', text: /\$3,000.00/
      assert_selector '.test-spent-out-of-pocket', text: /\$0.00/
      assert_selector '.test-allowable-funds-for-year', text: /\$6,000.00/
    end

    select '2015-2016', from: "year_#{two_year_child.id}"
    assert_content 'Joe 2015'
    within "#collapse-#{two_year_child.id}" do
      assert_selector '.test-spent-funds', text: /\$200.00/
      assert_selector '.test-committed-funds', text: /\$2,500.00/
      assert_selector '.test-remaining-funds', text: /\$3,500.00/
      assert_selector '.test-spent-out-of-pocket', text: /\$0.00/
      assert_selector '.test-allowable-funds-for-year', text: /\$6,000.00/
    end
  end

  test 'status panel with no invoice amount or RTP amount' do
    fill_in_login(users(:no_invoice_amount))
    assert_current_path root_path
    skip 'What was this test for?'
  end
end
