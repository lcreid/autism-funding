ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module TestSessionHelpers
  def log_in(user =
             User.create!(email: 'me1@weenhanceit.com', password: 'password'))
    ## If the user's province has not been set - default it to BC
    if user.my_address.get_province_code.empty?
      user.my_address.province_code = province_codes('bc')
      user.save
    end

    ## If there are no phone numbers, create a home phone numbers
    if user.phone_numbers.size == 0
      user.my_home_phone.phone_number = '3335557777'
      user.save
    end

    post new_user_session_path,
         params: {
           user: {
             email: user.email,
             password: 'password',
             remember_me: 0
           },
           commit: 'Log in'
         }
    user
  end

  # This one works for Capybara tests. I have no idea why the above doesn't.
  def fill_in_login(user =
                    User.create!(email: 'me@weenhanceit.com',
                                 password: 'password'))
    visit(new_user_session_path)
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'
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
             password: 'secret08',
             remember_me: 0
           },
           commit: 'Log in'
         }
  end

  def show_errors(line, obj)
    unless obj.respond_to? :errors
      puts "#{line}:  Does not respond to errors"
    else
      if obj.errors.messages.size == 0
        puts "#{line}:  No Errors"
      else
        puts "#{line}:  --Error List:"
        obj.errors.messages.each do |m|
          puts "**Error: #{m}"
        end
      end
    end
  end

  def show_user_status (line = '', user = controller.current_user)
    puts ""
    puts " -- User status #{line} --"
    puts "                 id: #{user.id}"
    puts "    addresses[0].id: #{user.addresses[0].id}"
    puts "     addresses.size: #{user.addresses.size}"
    puts " phone_numbers.size: #{user.phone_numbers.size}"
    puts "       Last Updated: #{user.updated_at}"
    puts "          User Name: #{user.my_name}"
    puts "         User email: #{user.email}"
    puts "            Address: #{user.my_address.get_address}"
    puts "                     City: #{user.my_address.city}  Prov: #{user.my_address.get_province_code}   #{user.my_address.get_postal_code}"
    puts "  Missing Key Info?: #{user.missing_key_info?}"
    puts "       BC Resident?: #{user.bc_resident?} "
    puts "Can Create New RTP?: #{user.can_create_new_rtp?}"
    puts "   Can See My Home?: #{user.can_see_my_home?}"
    puts " -----------------"
  end
end

# Added for Capybara
require 'capybara/rails'
require 'minitest/rails/capybara'
require 'capybara/poltergeist'
require 'database_cleaner'

class CapybaraTest < Capybara::Rails::TestCase
  # # Make the Capybara DSL available in all integration tests
  # include Capybara::DSL
  # include Capybara::Assertions
  #
  # # Reset sessions and driver between tests
  # # Use super wherever this method is redefined in your individual test classes
  # def teardown
  #   Capybara.reset_sessions!
  #   Capybara.use_default_driver
  # end
end
# End Capybara

class PoltergeistTest < CapybaraTest
  # You need the following so the database cleaner's work won't get rolled
  # back by the test case.
  self.use_transactional_tests = false

  def setup
    # User.all.each { |u| Rails.logger.debug "Starting test: #{u.preferences}" if u.preferences }
    # Rails.logger.debug 'Starting test...'
    DatabaseCleaner.strategy = :truncation
    Capybara.javascript_driver = :poltergeist
    Capybara.current_driver = Capybara.javascript_driver
    # Was getting lots of random failures, so try extending the wait time.
    # That wasn't the issue. Taking this out. But it doesn't seem to make
    # a different either way in the run time of the test.
    # Capybara.default_max_wait_time = 5
    super
  end

  def assert_select(locator, options)
    # Rails.logger.debug "assert_select #{locator} #{options}"
    # User.all.each { |u| Rails.logger.debug "In assert_selector: #{u.preferences}" if u.preferences }
    super
    # Rails.logger.debug 'assert done'
  end

  def teardown
    super
    # User.all.each { |u| Rails.logger.debug "In clean: #{u.preferences}" if u.preferences }
    # Rails.logger.debug 'Cleaning database...'
    DatabaseCleaner.clean
    # Rails.logger.debug '...database cleaned.'
    # User.all.each { |u| Rails.logger.debug "In clean: #{u.preferences}" if u.preferences }
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
