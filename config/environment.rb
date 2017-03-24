# Load the Rails application.
require_relative 'application'

# From: http://railscasts.com/episodes/39-customize-field-error
# ActionView::Base.field_error_proc = proc do |html_tag, _instance_tag|
#   "<span class='field_error'>#{html_tag}</span>".html_safe
# end

# Initialize the Rails application.
Rails.application.initialize!
