class HomeController < ApplicationController
  def index
    @funded_people = current_user.funded_people
    @funded_people.each do |child|
      fy = params[:year][child.id.to_s]
      child.selected_fiscal_year = fy if fy
    end if params[:year]
  end
end
