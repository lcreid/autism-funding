require 'test_helper'

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelpers

  test 'should get new' do
    skip "Can't create an invoice for a child that doesn't belong to the current user"
    #    get invoices_new_url
    #-- Log In
    log_in
    # -- Create a new FundedPerson record
    @funded_person = FundedPerson.first
    # puts 'Here i am!!'
    get new_funded_person_invoice_path(@funded_person)
    assert_response :success
  end

  test "Phil's trying to figure out what's going on" do
    skip "Can't create an invoice for a child that doesn't belong to the current user"
    #    get invoices_new_url
    #-- Log In
    login_known(:int_user1)
    # -- Create a new FundedPerson record
    @funded_person = FundedPerson.first
    # puts "Current User: #{controller.current_user.email}"
    # puts "Funded Person Name: #{@funded_person.my_name} " \
    #      "and id: #{@funded_person.id}"
    assert users(:int_user1).my_name, controller.current_user.my_name
    assert users(:int_user1).email, controller.current_user.email

    # FIXME: The following should probably fail, since we shouldn't get to a
    # funded person who isn't associated with the current user
    get new_funded_person_invoice_path(@funded_person)
    puts "The URL: #{@controller.instance_variable_get(:@url)}"
    assert_response :success
    puts "Can I see @url #{@url}"
  end

  test "Phil's trying to get fancy" do
    login_known(:int_user1)
    # puts "Current User: #{controller.current_user.my_name} at: " \
    #      "#{controller.current_user.email}"
    assert users(:int_user1).my_name, controller.current_user.my_name
    assert users(:int_user1).email, controller.current_user.email
  end
end
