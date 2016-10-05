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
      year_selector = "year_#{child.id}"
      assert_select(year_selector, selected: '2016-2017')
      within '.form-list' do
        assert_selector 'tbody tr', count: 2
      end
      within '.invoice-list' do
        assert_no_selector 'tbody tr'
      end

      select '2015-2016', from: year_selector
    end

    # FIXME: Remove this and make the JavaScript work
    click_button 'Search'
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
