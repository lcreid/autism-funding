require 'test_helper'

class FormsTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  fixtures :cf0925s, :forms

  test 'simple get all forms' do
    fill_in_login
    visit forms_path
    assert_selector 'tr.form-row', count: 1
  end
end
