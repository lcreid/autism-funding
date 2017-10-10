ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails/capybara"
require "capybara/poltergeist"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def set_up_child(user_params = {}, child_params = {})
    default_user_params = {
      email: "a@example.com",
      password: "password",
      name_first: "a",
      name_last: "b",
      address: "a",
      city: "b",
      province_code_id: province_codes(:bc).id,
      postal_code: "V0V 0V0",
      home_phone_number: "3334445555"
    }
    user = User.new(default_user_params.merge(user_params))
    # user.addresses.build(address_line_1: 'a',
    #                      city: 'b',
    #                      province_code: province_codes(:bc),
    #                      postal_code: 'V0V 0V0')
    # user.phone_numbers.build(phone_type: 'Home', phone_number: '3334445555')
    default_child_params = {
      name_first: "a",
      name_last: "b",
      child_in_care_of_ministry: false,
      birthdate: "2003-11-30"
    }
    user.funded_people.build(default_child_params.merge(child_params))
  end

  SUPPLIER_ATTRS = {
    item_cost_1: 600,
    item_cost_2: 400,
    item_desp_1: "Conference",
    item_desp_2: "Workshop",
    part_b_fiscal_year: "2016-2017",
    supplier_address: "Supplier St",
    supplier_city: "Supplier City",
    supplier_contact_person: "Supplier Contact",
    supplier_name: "Supplier Name",
    supplier_phone: "8888888888",
    supplier_postal_code: "V0V 0V0"
  }.freeze

  PROVIDER_AGENCY_ATTRS = {
    agency_name: "Pay Me Agency",
    part_b_fiscal_year: "2016-2017",
    payment: "agency",
    service_provider_postal_code: "V0V 0V0",
    service_provider_address: "4400 Hastings St.",
    service_provider_city: "Burnaby",
    service_provider_phone: "7777777777",
    service_provider_name: "Ferry Man",
    service_provider_service_1: "Behaviour Consultancy",
    service_provider_service_amount: 2_000,
    service_provider_service_end: "2017-03-31",
    service_provider_service_fee: 120.00,
    service_provider_service_hour: "Hour",
    service_provider_service_start: "2016-12-01"
  }.freeze

  def set_up_provider_agency_rtp(child, attrs = {})
    set_up_rtp(child, PROVIDER_AGENCY_ATTRS.merge(attrs))
  end

  def set_up_supplier_rtp(child, attrs = {})
    set_up_rtp(child, SUPPLIER_ATTRS.merge(attrs))
  end

  def set_up_rtp(child, attrs)
    rtp = child.cf0925s.build(attrs)
    rtp.populate
    assert rtp.printable?,
      "RTP should be printable #{rtp.errors.full_messages} "\
      "User should be printable #{child.user.errors.full_messages}"

    rtp
  end
end

module TestSessionHelpers
  def log_in(user =
             User.create!(
               email: "me1@weenhanceit.com",
               password: "password",
               name_first: "parent_first_name",
               name_middle: "parent_middle_name",
               name_last: "parent_last_name",
               home_phone_number: "6048888887",
               work_phone_number: "6047777778",
               address: "parent_address",
               city: "parent_city",
               postal_code: "A0A 0A0"
             ))
    ## If the user's province has not been set - default it to BC
    if user.province_code_id.nil?
      user.province_code_id = province_codes("bc").id
      user.save
    end

    post new_user_session_path,
      params: {
        user: {
          email: user.email,
          password: "password",
          remember_me: 0
        },
        commit: "Log in"
      }
    user
  end

  # This one works for Capybara tests. I have no idea why the above doesn't.
  def fill_in_login(user =
                    User.create!(email: "me@weenhanceit.com",
                                 password: "password"))
    visit(new_user_session_path)
    expect has_field?("Email")
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"
  end

  # This one derived from Larry The Rails Guy's log_in
  def login_known(the_user)
    # Get an instance of the user
    user = users(the_user)
    # provide the credentials and log in
    # Note the encrypted_password in the yml was created using an
    # instance of User in console with a password as below
    post user_session_path,
      params: {
        user: {
          email: user.email,
          password: "secret08",
          remember_me: 0
        },
        commit: "Log in"
      }
  end

  def show_errors(line, obj)
    if obj.respond_to? :errors
      if obj.errors.messages.empty?
        puts "#{line}:  No Errors"
      else
        puts "#{line}:  --Error List:"
        obj.errors.messages.each do |m|
          puts "**Error: #{m}"
        end
      end
    else
      puts "#{line}:  Does not respond to errors"
    end
  end

  def show_user_status(line = "", user = controller.current_user)
    puts ""
    puts " -- User status #{line} --"
    puts "                 id: #{user.id}"
    puts "    addresses[0].id: #{user.addresses[0].id}"
    puts "     addresses.size: #{user.addresses.size}"
    puts " phone_numbers.size: #{user.phone_numbers.size}"
    puts "       Last Updated: #{user.updated_at}"
    puts "          User Name: #{user.my_name}"
    puts "         User email: #{user.email}"
    puts "            Address: #{user.address}"
    puts "                     City: #{user.city}  Prov: #{ProvinceCode.find(user.province_code_id).province_code}   #{user.postal_code}"
    puts "  Missing Key Info?: #{user.missing_key_info?}"
    puts "       BC Resident?: #{user.bc_resident?} "
    puts "Can Create New RTP?: #{user.can_create_new_rtp?}"
    puts "   Can See My Home?: #{user.can_see_my_home?}"
    puts " -----------------"
  end

  def show_matching_info(child, _delimiter = '\n')
    horiz_line = "---------------------------------------"
    fys = []
    puts ""
    puts horiz_line
    if !child.instance_of? FundedPerson
      puts "  --- This object is not of type FundedPerson --- "
    else
      puts "| Matching Information for #{child.my_name}, born #{child.my_dob}"
      puts horiz_line
      if child.cf0925s.empty?
        puts "|  This child has no CF0925s defined"
      else
        child.cf0925s.each do |rtp|
          fys << child.fiscal_year(rtp.start_date)
          puts "|  -- rtp -- object_id:  #{rtp.object_id}"
          puts "| Service Provider Name: #{rtp.service_provider_name}" if rtp.service_provider_name
          puts "| Agency Name: #{rtp.agency_name}" if rtp.agency_name
          puts "| Supplier Name: #{rtp.supplier_name}" if rtp.supplier_name
          rtp.printable? ? (puts "| printable") : (puts "| NOT printable")
          msg = "| "
          msg += "  Service Start: #{rtp.service_provider_service_start}" if rtp.service_provider_service_start
          msg += "  Service End: #{rtp.service_provider_service_end}" if rtp.service_provider_service_end
          puts msg
          puts "| Service Provider Amount: #{rtp.service_provider_service_amount}" if rtp.service_provider_service_amount
          puts "| Item 1 Cost: #{rtp.item_cost_1}" if rtp.item_cost_1
          puts "| Item 2 Cost: #{rtp.item_cost_2}" if rtp.item_cost_2
          puts "| Item 3: #{rtp.item_cost_3}" if rtp.item_cost_3
          if rtp.invoices.empty?
            puts "|  NO invoices Matched"
          else
            rtp.invoices.each do |inv|
              puts "|  MATCHED Invoice: #{inv.object_id}"
            end
          end
        end
      end
      puts horiz_line
      if child.invoices.empty?
        puts "|  This child has no Invoices defined"
      else
        child.invoices.each do |inv|
          fys << child.fiscal_year(inv.start_date)
          puts "|  -- invoice -- object_id:  #{inv.object_id}"
          puts "| Invoice From: #{inv.invoice_from}" if inv.invoice_from
          puts "| Service Provider Name: #{inv.service_provider_name}" if inv.service_provider_name
          puts "| Invoice Date: #{inv.invoice_date}" if inv.invoice_date
          puts "| Amount: #{inv.invoice_amount}" if inv.invoice_amount
          #          puts "| Supplier Name: #{rtp.supplier_name}" if rtp.supplier_name
          msg = "| "
          msg += "  Service Start: #{inv.service_start}" if inv.service_start
          msg += "  Service End: #{inv.service_end}" if inv.service_end
          puts msg
          inv.valid?(:complete) ? (puts "| complete") : (puts "| !!! NOT complete")
          # if inv.cf0925s.size < 1
          #   puts "NOT matched to any RTPs"
          # else
          #   inv.cf0925s.each do |rtp|
          #     puts "| MATCHED TO rtp: #{rtp.object_id}"
          #   end
          # end
        end
      end
      unless fys.empty?
        puts horiz_line
        fys.uniq.each do |fy|
          puts "| --- Status for Fiscal Year: #{fy}"
          stat = child.status(fy)
          puts "|  Committed Funds: #{stat.committed_funds}"
          puts "|  Spent Funds: #{stat.spent_funds}"
          puts "|  Remaining Funds: #{stat.remaining_funds}"
          puts "|  Out Of Pocket: #{stat.spent_out_of_pocket}"
        end
      end

    end
    puts horiz_line
  end
end

# Added for Capybara
require "capybara/rails"
require "minitest/rails/capybara"
require "capybara/poltergeist"
require "database_cleaner"

class CapybaraTest < Capybara::Rails::TestCase
  # # Make the Capybara DSL available in all integration tests
  # include Capybara::DSL
  # include Capybara::Assertions
  #
  # # Reset sessions and driver between tests
  # # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
# End Capybara

class PoltergeistTest < CapybaraTest
  # You need the following so the database cleaner's work won't get rolled
  # back by the test case.
  self.use_transactional_tests = false
  Capybara.javascript_driver = :poltergeist

  # def assert_select(locator, options)
  #   # Rails.logger.debug "assert_select #{locator} #{options}"
  #   # User.all.each { |u| Rails.logger.debug "In assert_selector: #{u.preferences}" if u.preferences }
  #   super
  #   # Rails.logger.debug 'assert done'
  # end
  #
  def cancel_request
    page.evaluate_script('$("body.pending").deleteClass("pending");')
    # puts 'CANCEL_REQUEST?'
  end

  ##
  # Check to see if the request has completed (see `start_request`)
  def pending_request?
    result = page.evaluate_script('$("body.pending").length')
    # puts "PENDING_REQUEST?: #{result} #{result.class}"
    result
  end

  def setup
    # User.all.each { |u| Rails.logger.debug "Starting test: #{u.preferences}" if u.preferences }
    # Rails.logger.debug 'Starting test...'
    DatabaseCleaner.strategy = :truncation
    Capybara.current_driver = Capybara.javascript_driver
    # Was getting lots of random failures, so try extending the wait time.
    # That wasn't the issue. Taking this out. But it doesn't seem to make
    # a difference either way in the run time of the test.
    # Trying it again...
    # Capybara.default_max_wait_time = 5
    super
  end

  ##
  # Indicate that the test is about to do a request that might take some time,
  # either through non-trivial Javascript, or especially AJAX calls.
  # This really should take a block and wrap the block, but because it
  # may depend on Javascript to remove the .pending class, or a single request
  # can remove the .pending class, it won't work.
  def start_request
    # evaluate_script('$("body").prepend("<span class=\"pending\"></span>");')
    # result = evaluate_script('$("span.pending").length;')
    # puts "start_request jQuery found: #{result}"
    # puts "capybara found: #{has_css?('span', wait: 10)}"
    # page.assert_selector 'span.pending'
    # puts 'Starting Request'
    evaluate_script('$("body").addClass("pending");')
    # result = evaluate_script('$("body.pending").length;')
    # puts "start_request jQuery found: #{result}"
    # puts "capybara found: #{has_css?('body.pending', wait: 10)}"
    # assert_selector 'body.pending'
    # puts method(:has_css?)
    # puts method(:assert_selector)
    # page.assert_selector 'body.pending'
  end

  def teardown
    click_link "Log out"
    assert_content "Signed out successfully."
    super
    # User.all.each { |u| Rails.logger.debug "In clean: #{u.preferences}" if u.preferences }
    # Rails.logger.debug 'Cleaning database...'
    DatabaseCleaner.clean
    # Rails.logger.debug '...database cleaned.'
    # User.all.each { |u| Rails.logger.debug "In clean: #{u.preferences}" if u.preferences }
  end

  def wait_for_request
    # puts 'Waiting for body.pending to go away.'
    assert_no_selector "body.pending"
  end
end

# I got this from: https://github.com/chriskottom/minitest_cookbook_source/issues/3
# To fix transacation issues with Poltergeist tests
# Without this I was getting random failures. Seems to be necessary.
# But the it looks like Postgres may not like shared connections.
# class ActiveRecord::Base
#   mattr_accessor :shared_connection
#   @@shared_connection = nil
#   def self.connection
#     @@shared_connection || retrieve_connection
#   end
# end
# ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
# End transactions fix.

# Support Devise controller tests (only)
class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end
# End Devise
