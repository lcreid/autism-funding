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
    click_link child.my_name
    assert_selector("#collapse-#{child.id}.in")

    year_selector = "year_#{child.id}"

    within "#collapse-#{child.id}" do
      expect has_select?('#' + year_selector, selected: '2016-2017')
      within '.form-list' do
        expect has_selector?('tbody tr', count: 2)
      end
      within '.invoice-list' do
        expect has_selector?('tbody tr td',
                             text: 'You have no invoices in this fiscal year')
      end
    end

    start_request
    Rails.logger.debug { 'Selecting 2015-2016...' }
    select '2015-2016', from: year_selector
    wait_for_request

    expect has_select?('#' + year_selector, selected: '2015-2016')

    within "#collapse-#{child.id}" do
      assert_content 'Joe 2015'
      within '.form-list' do
        expect has_selector?('tbody tr', count: 1)
      end
      within '.invoice-list' do
        expect has_selector?('tbody tr', count: 1)
      end
    end
  end

  test 'Set fiscal year based on last RTP' do
    fill_in_login(user = users(:years))

    child = user.funded_people.find { |x| x.name_first == 'Two' }
    click_link child.my_name
    expect has_selector?("#collapse-#{child.id}.in")

    year_selector = "year_#{child.id}"
    within "#collapse-#{child.id}" do
      expect has_select?(year_selector, selected: '2016-2017')
      click_link('New Request to Pay')
    end

    # sleep 5
    # assert_current_path new_funded_person_cf0925_path(child)
    # puts find('#cf0925_service_provider_service_start').inspect
    # expect has_selector?('#cf0925_service_provider_service_start')
    # expect has_selector?('#cf0925_service_provider_service_end')
    # assert_content 'Parent/Guardian Information'
    fill_in 'Start Date', with: '2015-09-01'
    fill_in 'End Date', with: '2015-12-31'
    # find('#cf0925_service_provider_service_start').set('2015-09-01')
    # find('#cf0925_service_provider_service_start').set('2015-12-31')
    click_button 'Save'
    # click_link 'Home'
    assert_current_path home_index_path
    # puts page.html

    within "#collapse-#{child.id}" do
      # expect has_select?(year_selector, selected: '2016-2017')
      expect has_select?(year_selector, selected: '2015-2016')
    end
    # byebug # rubocop:disable Lint/Debugger
  end
end
