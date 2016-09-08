class Cf0925sController < ApplicationController
  def index
    @cf0925s = Cf0925.all
  end

  def new
    @cf0925 = Cf0925.new
    @cf0925.funded_person = FundedPerson.find(params[:funded_person_id])

    copy_parent_to_form
    copy_child_to_form
  end

  def create
    # pp(params.as_json)
    # pp(cf0925_params.as_json)
    @cf0925 = Cf0925.new(cf0925_params)
    # https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2010-3933
    @cf0925.funded_person = FundedPerson.find(params[:funded_person_id])
    user = @cf0925.funded_person.user
    # puts "User has #{user.phone_numbers.size} phone numbers"
    pp(user_params.as_json)
    user.update(user_params)
    puts "Middle name: #{user.name_middle}"
    puts "Address: #{user.addresses.first.as_json}"
    copy_parent_to_form
    # puts "User has #{user.phone_numbers.size} phone numbers"
    # puts 'User save failed' unless user.save
    # puts "User has #{user.phone_numbers.size} phone numbers"
    # user.phone_numbers.each(&:save)
    # puts user.errors.full_messages
    if @cf0925.save && user.save
      redirect_to cf0925_path(@cf0925)
    else
      render :new
    end
  end

  def show
    @cf0925 = Cf0925.find(params[:id])
  end

  private

  def cf0925_params
    params
      .require(:cf0925)
      .permit(Cf0925.column_names + [])
  end

  def user_params
    phone_attributes = [
      :id,
      :user_id,
      :phone_extension,
      :phone_number,
      :phone_type
    ]
    params[:cf0925][:funded_person_attributes]
      .require(:user_attributes)
      .permit(
        #   funded_person_attributes: [
        #     :id,
        #     user_attributes: [
        :id,
        :name_first,
        :name_middle,
        :name_last,
        phone_numbers_attributes: phone_attributes,
        addresses_attributes: [
          :id,
          :address_line_1,
          :city,
          :postal_code
        ]
      #     ]
      #   ]
      )
  end

  def copy_parent_to_form
    @cf0925.parent_last_name = @cf0925.user.name_last
    @cf0925.parent_first_name = @cf0925.user.name_first
    @cf0925.parent_middle_name = @cf0925.user.name_middle
    @cf0925.home_phone = @cf0925.user.my_home_phone.full_number
    @cf0925.work_phone = @cf0925.user.my_work_phone.full_number
    @cf0925.parent_address = @cf0925.user.my_address.address_line_1
    @cf0925.parent_city = @cf0925.user.my_address.city
    @cf0925.parent_postal_code = @cf0925.user.my_address.postal_code
  end

  # def copy_form_to_parent
  #    @cf0925.user.name_last = @cf0925.parent_last_name
  #    @cf0925.user.name_first = @cf0925.parent_first_name
  #    @cf0925.user.name_middle = @cf0925.parent_middle_name
  #    @cf0925.user.my_home_phone.full_number = @cf0925.home_phone
  #    @cf0925.user.my_work_phone.full_number = @cf0925.work_phone
  #    @cf0925.user.my_address.address_line_1 = @cf0925.parent_address
  #    @cf0925.user.my_address.city = @cf0925.parent_city
  #    @cf0925.user.my_address.postal_code = @cf0925.parent_postal_code
  # end
  #
  def copy_child_to_form
    @cf0925.child_last_name = @cf0925.funded_person.name_last
    @cf0925.child_first_name = @cf0925.funded_person.name_first
    @cf0925.child_middle_name = @cf0925.funded_person.name_middle
    @cf0925.child_dob = @cf0925.funded_person.my_dob
  end
end
