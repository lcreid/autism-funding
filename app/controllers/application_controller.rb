class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login

  private

#  def after_sign_up_path_for(resource)
#    static_contact_us_path
#  end

#  def after_sign_in_path_for(resource)
#    other_resources_index_path
#  end

  def require_login
    # There are a lot of suggestions on the web about how to do this.
    # I wanted to go to the welcome page if the user isn't logged in.
    # If the user is logged in, they should go to their home page.
    # The Devise `authenticate_user!` method goes to its login page.
    unless ['devise/sessions', 'devise/registrations'].include?(params[:controller])
      redirect_to welcome_index_path unless user_signed_in?
    end
  end
end
