require 'test_helper'
require 'capybara/poltergeist'

##
# Integration tests for the fiscal year filter.
class CompleteCf0925Test < CapybaraTest
  include TestSessionHelpers

  def setup
    Capybara.javascript_driver = :poltergeist
    Capybara.current_driver = Capybara.javascript_driver
    # Capybara.register_driver :poltergeist do |app|
    #   # Capybara::Poltergeist::Driver.new(app, timeout: 60)
    #   Capybara::Poltergeist::Driver.new(app,
    #                                     # js_errors: false,
    #                                     # #inspector: true,
    #                                     # phantomjs_logger: Rails.logger,
    #                                     # logger: nil,
    #                                     # phantomjs_options: ['--debug=no', '--load-images=no', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1'],
    #                                     debug: true)
    # end
  end

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
      assert_select(year_selector, selected: '2015-2016')
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
