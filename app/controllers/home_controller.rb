class HomeController < ApplicationController
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
    child = FundedPerson.find(params[:funded_person_id])
    child.set_childs_panel_state(params[:panel_state])
    head :ok, content_type: 'text/html'
  end

  ##
  # Acknowlege the fact that this site only applies to BC residents
  # This ensures that the Warning panel no longer appears on my_home_phone
  def acknowledge_bc_instructions
    current_user.set_bc_warning_acknowledgement(true)
    redirect_to home_index_path
  end
end
