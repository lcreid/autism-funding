class StaticController < ApplicationController
  skip_before_action :require_login, only: :contact_us

  def non_supported
  end

  def contact_us
  end

  def bc_instructions
  end
end
