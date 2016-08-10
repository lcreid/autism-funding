class MyProfileController < ApplicationController
  def index
    set_objects
  end

  def edit
    set_objects
    if flash[:save_errors]
      ##------------------------------------------------------------------------
      ## We are here because we were redirected from a save due to errors
      ## Reproduce the errors
      add_data_for_user
    end
  end

  def update
    flash[:save_errors] = nil
    set_objects
    add_data_for_user
    # -- Save the Name data
    unless @my_address.save
      @my_address.errors.messages.each do |m|
        add_flash "Address", m
      end
    end
    # -- Save the Address data
    unless @my_address.save
      @my_address.errors.messages.each do |m|
        add_flash "Address", m
      end
    end
    # -- Save the Home Phone
    unless @home_phone.save
      @home_phone.errors.messages.each do |m|
        add_flash "Home Phone Number", m
      end
    end
    # -- Save the Work Phone
    unless @work_phone.save
      @work_phone.errors.messages.each do |m|
        add_flash "Home Phone Number", m
      end
    end
    if flash[:save_errors].nil?
      redirect_to my_profile_index_path(request.parameters)
    else
      redirect_to my_profile_edit_path(request.parameters)
    end
  end



  #-- Private Methods -----------------------------------------------
  private
    def add_data_for_user
      current_user.update(params.require(:user).permit(:name_first, :name_middle, :name_last))
      @my_address.update(params.require(:address).permit( :province_code_id, :address_line_1, :address_line_2, :city, :postal_code))
      @home_phone.update(params.require(:home_phone_number).permit( :phone_number))
      @work_phone.update(params.require(:work_phone_number).permit( :phone_number, :phone_extension))
    end

    def set_objects
      @my_address = current_user.my_address
      @home_phone = current_user.my_home_phone
      @work_phone = current_user.my_work_phone
    end

    def add_flash (the_group, the_message)
      if flash[:save_errors].nil?
        flash[:save_errors] = "<u>Please Correct the Following Problems and Re-Save</u><br><br>"
      else
        flash[:save_errors] += "<br>"
      end
      flash[:save_errors] += "#{the_group}: #{the_message}"
    end
end
