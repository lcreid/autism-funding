class Cf0925sController < ApplicationController
  def index
    @cf0925s = Cf0925.all
  end

  def show
    @cf0925 = Cf0925.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        @cf0925.generate_pdf
        send_file @cf0925.pdf_output_file,
                  disposition: :inline,
                  type: :pdf,
                  filename: @cf0925client_pdf_file_name
      end
    end
  end

  # The canonical way of new and create with shallow routes is to have an
  # instance variable for both objects in new and create, but only have an
  # instance variable for the object from this controller in edit and update.
  # http://stackoverflow.com/questions/9772588/when-using-shallow-routes-different-routes-require-different-form-for-arguments
  def new
    @cf0925 = Cf0925.new
    @cf0925.funded_person =
      @funded_person =
        FundedPerson.find(params[:funded_person_id])

    copy_parent_to_form
    copy_child_to_form
  end

  def edit
    @cf0925 = Cf0925.find(params[:id])
    # puts @cf0925.funded_person.inspect
    # Get the missing fields, aka help info, for the object
    @cf0925.printable?
  end

  def create
    # pp(params.as_json)
    # pp(cf0925_params.as_json)
    @cf0925 = Cf0925.new(cf0925_params)
    # https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2010-3933
    @cf0925.funded_person =
      @funded_person =
        FundedPerson.find(params[:funded_person_id])
    # TODO: Do I really need to save user separately?
    user = @cf0925.funded_person.user
    # puts "User has #{user.phone_numbers.size} phone numbers"
    # pp(user_params.as_json)
    user.update(user_params)
    # puts "Middle name: #{user.name_middle}"
    # puts "Address: #{user.addresses.first.as_json}"
    copy_parent_to_form
    copy_child_to_form
    # puts "User has #{user.phone_numbers.size} phone numbers"
    # puts 'User save failed' unless user.save
    # puts "User has #{user.phone_numbers.size} phone numbers"
    # user.phone_numbers.each(&:save)
    # puts user.errors.full_messages
    # puts 'Cf0925 save failed' unless @cf0925.save
    # puts @cf0925.errors.full_messages
    if @cf0925.save && user.save
      # Get the missing fields, aka help info, for the object
      # @cf0925.printable? FIXME: Useless since we're redirecting
      # TODO: why can't I just render :edit here?
      redirect_to edit_cf0925_path(@cf0925)
    else
      # Get the missing fields, aka help info, for the object
      @cf0925.printable?
      render :new
    end
  end

  def update
    @cf0925 = Cf0925.find(params[:id])
    @cf0925.update(cf0925_params)
    user = @cf0925.funded_person.user
    user.update(user_params)
    copy_parent_to_form
    copy_child_to_form

    if @cf0925.save && user.save
      # Get the missing fields, aka help info, for the object
      # @cf0925.printable? FIXME: Useless since we're redirecting
      # TODO: why can't I just render :edit here?
      redirect_to edit_cf0925_path(@cf0925)
    else
      # Get the missing fields, aka help info, for the object
      @cf0925.printable?
      render :edit
    end
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
    # puts "Before: #{@cf0925.child_dob}"
    @cf0925.child_last_name = @cf0925.funded_person.name_last
    @cf0925.child_first_name = @cf0925.funded_person.name_first
    @cf0925.child_middle_name = @cf0925.funded_person.name_middle
    @cf0925.child_dob = @cf0925.funded_person.my_dob
    # puts "After: #{@cf0925.child_dob}"
  end
end
