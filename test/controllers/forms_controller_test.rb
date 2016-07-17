require 'test_helper'

class FormsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get forms_path
    assert_response :success
  end
end
