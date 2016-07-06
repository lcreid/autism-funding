class MyProfileController < ApplicationController
  before_action :authenticate_user!
  def index
    if user_signed_in?
      logger.debug "We !! are in the MyProfileController #{current_user.display_my_name}"
    else
      logger.debug "We !! are in the MyProfileController "
    end
  end

  def edit
    if flash[:save_errors]
      ##------------------------------------------------------------------------
      ## We are here because we were redirected from a save due to errors
      ## Reproduce the errors
      add_data_for_user
    end
  end

  def update
    add_data_for_user
    if current_user.valid?
      if current_user.save
        redirect_to my_profile_index_path
      else
        flash[:save_errors] = "save errors"
        redirect_to my_profile_edit_path(request.parameters)
      end
    else
      flash[:save_errors] = "save errors"
      redirect_to my_profile_edit_path(request.parameters)
    end
  end



  #-- Private Methods -----------------------------------------------
  private
    def add_data_for_user
      tmp_user = User.new(params.require(:user).permit(:name_first, :name_middle, :name_last, :address_line_1, :address_line_2, :city, :postal_code))
      current_user.name_first = tmp_user.name_first
      current_user.name_middle = tmp_user.name_middle
      current_user.name_last = tmp_user.name_last
      current_user.address_line_1 = tmp_user.address_line_1
      current_user.address_line_2 = tmp_user.address_line_2
      current_user.city = tmp_user.city
      current_user.postal_code = tmp_user.postal_code
    #  current_user.postal_code = tmp_user.postal_code
    end
end
