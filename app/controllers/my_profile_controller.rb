class MyProfileController < ApplicationController
  def index
    set_objects
  end

  def edit
    unless params[:user].nil?
      current_user.assign_attributes(user_params)
    end
    # set_objects
    @warning = nil
    unless current_user.valid?
      @warning = 'Your information cannot be saved until you have corrected the information highlighted below'
    end
    # Ensure there is always one new funded person that can be filled in
    current_user.funded_people.new
  end

  # def help_pip(line)
  #   cnt = 0
  #   current_user.funded_people.each do |fp|
  #     unless fp.id.nil?
  #       cnt += 1
  #     end
  #   end
  #   logger.debug "#{Time.now.strftime('%H:%M:%S.%L')}  #{line}: size: #{current_user.funded_people.size}  real: #{cnt}   :xbyk----"
  # end


  def update
    if current_user.update(user_params)
      redirect_to root_path
    else
      redirect_to my_profile_edit_path(request.parameters)
    end
  end

#   def add_to_flash(from_whence)
#     flash[:save_errors] || flash[:save_errors] = "---- Start----"
#     flash[:save_errors] += "<br><br>Hit Update from #{from_whence}"
#     flash[:save_errors] += "<br><b>current_user.valid?:</b> [#{current_user.valid?}]"
#     # flash[:save_errors] += "<br><b>current_user.errors.messages.size:</b> [#{current_user.errors.messages.size}]"
#     flash[:save_errors] += "<br><b>current_user.funded_people.size:</b> [#{current_user.funded_people.size}]"
# #    flash[:save_errors] += "<br><b>params[:user][:addresses_attributes]['0'].as_json:</b> [#{params[:user][:addresses_attributes]['0'].as_json}]"
# #    flash[:save_errors] += "<br><b>user_params[:user][:phone_numbers_attributes]['0'].as_json:</b> [#{user_params[:user][:phone_numbers_attributes]['0'].as_json}]"
#     # the_hash = user_params
# #    the_hash['phone_numbers_attributes']['0'].each do |key|
# #      flash[:save_errors] += " <u> #{key} </u>"
# #    end
# #    flash[:save_errors] += "<br><b>the_hash['phone_numbers_attributes']['0'].as_json:</b> [#{the_hash['phone_numbers_attributes']['0'].as_json}]"
# #    flash[:save_errors] += "<br><b>params[:user][:phone_numbers_attributes]['1'].as_json:</b> [#{params[:user][:phone_numbers_attributes]['1'].as_json}]"
# #    tmp = current_user.phone_numbers[0]
# #    flash[:save_errors] += "<br><b>From current_user:</b>  id: #{tmp.id} type: #{tmp.phone_type} number: #{tmp.phone_number}"
#
#   end

  def x_update
    flash[:save_errors] = nil
    set_objects
#    add_data_for_user

    if flash[:save_errors].nil?
      # redirect_to my_profile_index_path(request.parameters)
    #  redirect_to root_path
      redirect_to my_profile_edit_path(request.parameters)
    else
      redirect_to my_profile_edit_path(request.parameters)
    end
  end

  #-- Private Methods -----------------------------------------------

  private

  def user_params
    params.require(:user).permit(:name_first, :name_middle, :name_last, :address, :city, :postal_code, :province_code_id, :home_phone_number, :work_phone_number,:work_phone_extension, funded_people_attributes: [:id, :name_first, :name_middle, :name_last, :birthdate, :child_in_care_of_ministry, :_destroy])
  end

  def z_add_data_for_user
    # Whitelist the parameters for update
    user_params = params.require(:user).permit(:name_first, :name_middle, :name_last, funded_people_attributes: [:id, :name_first, :name_middle, :name_last, :birthdate, :child_in_care_of_ministry, :_destroy])
    address_params = params.require(:address).permit(:province_code_id, :address_line_1, :address_line_2, :city, :postal_code)
    home_phone_params = params.require(:home_phone_number).permit(:phone_number)
    work_phone_params = params.require(:work_phone_number).permit(:phone_number, :phone_extension)

    ## Update User (including Funded Children from nested forms)
    unless current_user.update(user_params)
      current_user.errors.full_messages.each do |m|
        if m.include? 'Funded people'
          add_flash 'Funded Children: ', m
        else
          add_flash 'User: ', m
        end
      end
    end
    ## Update Address
    old_pc_id = @my_address.province_code_id
    new_pc_id = address_params['province_code_id'.to_sym]
    unless old_pc_id == new_pc_id
      current_user.set_bc_warning_acknowledgement(false)
      # logger.debug { "**** CHANGED: Orig pcid: #{old_pc_id}   New: #{new_pc_id}" }
    end
    unless @my_address.update(address_params)
      @my_address.errors.full_messages.each do |m|
        add_flash 'Address', m
      end
    end
    ## Update Home Phone
    unless @home_phone.update(home_phone_params)
      @home_phone.errors.full_messages.each do |m|
        add_flash 'Home Phone Number', m
      end
    end
    ## Update Work Phone
    unless @work_phone.update(work_phone_params)
      @work_phone.errors.full_messages.each do |m|
        add_flash 'Work Phone Number', m
      end
    end
  end #-- End Method ---------------------------------------------------------

  def set_objects
    @my_address = current_user.my_address
    @home_phone = current_user.my_home_phone
    @work_phone = current_user.my_work_phone
    # current_user.funded_people.new
  end

  def xadd_flash(the_group, the_message)
    if flash[:save_errors].nil?
      flash[:save_errors] = '<u>Please Correct the Following and Re-Save</u><br><br>'
    else
      flash[:save_errors] += '<br>'
    end
    flash[:save_errors] += "#{the_group}: #{the_message}"
  end
end
