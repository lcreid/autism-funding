require 'test_helper'

##
# Integration tests for the fiscal year filter.
class CompleteCf0925Test < CapybaraTest
  include TestSessionHelpers

  test 'start on current fiscal year' do
    fill_in_login(user = users(:years))
    assert_current_path root_path
    child = user.funded_people.select { |x| x.name_first == 'Two' }.first
    within "#collapse-#{child.id}" do
      assert_select('Year', selected: '2016-2017')
    end
    within '.form-list' do
      assert_selector 'tr', count: 2
    end
    within '.invoice-list' do
      assert_no_selectors 'tr'
    end
  end
end
