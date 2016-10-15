require 'test_helper'
require 'capybara/poltergeist'

##
# Integration tests for the fiscal year filter.
class FiscalYearFilterTest < PoltergeistTest
  include TestSessionHelpers

  test 'start on current fiscal year' do
    fill_in_login(user = users(:years))
    assert_current_path root_path
    child = user.funded_people.find { |x| x.name_first == 'Two' }
    within "#collapse-#{child.id}" do
      year_selector = "year_#{child.id}"
      assert_select(year_selector, selected: '2016-2017')
      within '.form-list' do
        assert_selector 'tbody tr', count: 2
      end
      within '.invoice-list' do
#        assert_no_selector 'tbody tr'
        assert_selector 'tbody tr td', text: "You have no invoices in this fiscal year"
      end

      Rails.logger.debug { 'Selecting 2015-2016...' }
      select '2015-2016', from: year_selector
      assert_select(year_selector, selected: '2015-2016')
      assert_content 'Joe 2015'
    end

    # page.execute_script("console.log('From #{__FILE__}');")
    # page.execute_script("$('form.fiscal-year-selector').submit();")
    within "#collapse-#{child.id}" do
      within '.form-list' do
        assert_selector 'tbody tr', count: 1
      end
      within '.invoice-list' do
        assert_selector 'tbody tr', count: 1
      end
    end
  end
end
