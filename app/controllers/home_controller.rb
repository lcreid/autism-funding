class HomeController < ApplicationController
  before_action :check_if_can_see_my_home

  def check_if_can_see_my_home
    redirect_to my_profile_edit_path unless current_user.can_see_my_home?
  end

  def index
    @funded_people = current_user.funded_people
    @funded_people.each do |child|
      fy = params[:year][child.id.to_s]
      child.selected_fiscal_year = fy if fy
      logger.debug do
        "Child: #{child.my_name} " \
        "Fiscal year: #{fy} " \
        'Number of CF0925s: ' \
        "#{child.cf0925s_in_selected_fiscal_year.size} " \
        'Number of invoices: ' \
        "#{child.invoices_in_selected_fiscal_year.size}"
      end
    end if params[:year]
  end

  ##
  # Set the state of a panel on the index view
  def set_panel_state
    # puts "set panel state: #{params[:panel_state]}"
    child = FundedPerson.find(params[:funded_person_id])
    child.set_childs_panel_state(params[:panel_state])
    head :ok # , content_type: 'text/html'
    # render inline: ''
  end

end
