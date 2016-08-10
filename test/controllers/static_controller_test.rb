require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers
  
  test "should get non_supported" do
    log_in
    get static_non_supported_url
    assert_response :success
  end

  test "should get contact_us" do
    log_in
    get static_contact_us_url
    assert_response :success
  end

  test "should get bc_instructions" do
    log_in
    get static_bc_instructions_url
    assert_response :success
  end

end
