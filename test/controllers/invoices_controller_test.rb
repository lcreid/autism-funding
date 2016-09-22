require 'test_helper'

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  test "should get new" do
#    get invoices_new_url
    #-- Log In
    log_in
    # -- Create a new FundedPerson record
    @funded_person = FundedPerson.first

    get new_funded_person_invoice_path(@funded_person.id)
    assert_response :success
  end

end
