require 'test_helper'

class FormsTest < ActionDispatch::IntegrationTest
  test 'simple get all forms' do
    visit forms_path
    assert_selector 'tr.form-row', count: 1
  end
end
