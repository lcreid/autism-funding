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
             User.create!(email: 'me@weenhanceit.com', password: 'password'))

    post new_user_session_path,
         params: {
           user: {
             email: user.email,
             password: 'password',
             remember_me: 0
           },
           commit: 'Log in'
         }
  end

  # This one works for Capybara tests. I have no idea why the above doesn't.
  def fill_in_login
    user = User.create!(email: 'me@weenhanceit.com', password: 'password')
    visit(new_user_session_path)
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'
  end
end

# Added for Capybara
require 'capybara/rails'

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
# End Capybara
