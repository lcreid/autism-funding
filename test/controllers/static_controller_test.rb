require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  #  test "should get non_supported" do
  #    log_in
  #    get static_non_supported_url
  #    assert_response :success
  #  end

  test "should get contact_us" do
    # This url should be available to both logged and not logged users
    get static_contact_us_url
    assert_response :success

    log_in

    get static_contact_us_url
    assert_response :success
  end

  test "should get bc_instructions" do
    # This url should be available to both logged and not logged users
    get static_bc_instructions_url
    assert_response :success

    log_in

    get static_bc_instructions_url
    assert_response :success
  end
end
