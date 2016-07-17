require 'test_helper'

class FormsTest < ActionDispatch::IntegrationTest
  test 'simple get all forms' do
    visit forms_path
    puts 'Page: ' + page.body
    assert_selector 'tr.form-row', count: 1
  end
end
