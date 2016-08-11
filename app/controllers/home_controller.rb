class HomeController < ApplicationController
  def index
    @funded_people = current_user.funded_people
  end
end
