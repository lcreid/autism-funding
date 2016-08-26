require 'test_helper'

class MyProfileControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test 'create a user and fill in the user profile (but not child)' do
    visit '/'
    assert_equal '/', current_path
  end
end
