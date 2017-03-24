require 'test_helper'

class FormsControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  test 'should get index' do
    log_in
    get forms_path
    assert_response :success
  end
end
