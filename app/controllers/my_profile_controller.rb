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
    # TODO: I didn't realize you could use new this way.
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

  def xadd_flash(the_group, the_message)
    if flash[:save_errors].nil?
      flash[:save_errors] = '<u>Please Correct the Following and Re-Save</u><br><br>'
    else
      flash[:save_errors] += '<br>'
    end
    flash[:save_errors] += "#{the_group}: #{the_message}"
  end
end
