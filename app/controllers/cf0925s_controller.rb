class Cf0925sController < ApplicationController
  # default_form_builder AugmentedBootstrapForms
  # around_action :catch_data_not_found

  def index
    @cf0925s = current_user
               .funded_people
               .find(params[:funded_person_id])
               .cf0925s
  end

  def show
    @cf0925 = current_user.cf0925s.find(params[:id])

    respond_to do |format|
      format.pdf do
        @cf0925.generate_pdf
        send_file @cf0925.pdf_output_file,
          disposition: :inline,
          type: :pdf,
          filename: @cf0925.client_pdf_file_name
      end
    end
  end

  # The canonical way of new and create with shallow routes is to have an
  # instance variable for both objects in new and create, but only have an
  # instance variable for the object from this controller in edit and update.
  # http://stackoverflow.com/questions/9772588/when-using-shallow-routes-different-routes-require-different-form-for-arguments
  def new
    @funded_person =
      current_user.funded_people.find(params[:funded_person_id])
    @cf0925 = @funded_person.cf0925s.build

    copy_parent_to_form
    copy_child_to_form
    # puts "New error count: #{@cf0925.errors.count}"
    @cf0925.printable?
    # puts "New error count after printable?: #{@cf0925.errors.count}"
    @cf0925.part_b_fiscal_year = @funded_person.fiscal_year(Time.zone.today)
  end

  def edit
    @cf0925 = current_user.cf0925s.find(params[:id])
    # puts @cf0925.funded_person.inspect
    # Get the missing fields, aka help info, for the object
    @cf0925.printable?
    # puts "Edit error count: #{@cf0925.errors.count}"
    # puts @cf0925.errors[:parent_last_name]
  end

  def create
    # pp(params.as_json)
    # pp(cf0925_params.as_json)
    # https://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2010-3933
    @funded_person = current_user.funded_people.find(params[:funded_person_id])
    @cf0925 = @funded_person.cf0925s.build(cf0925_params)

    user = @cf0925.funded_person.user
    user.assign_attributes(user_params)
    copy_parent_to_form
    copy_child_to_form

    @cf0925.allocate
    # puts "#{__LINE__}: #{@cf0925.invoice_allocations.inspect}"

    notice = "Request saved."
    notice += " Parent data updated." if user.changed?

    # I didn't need to save addresses explicitly here.
    if @cf0925.save_with_user
      # Get the missing fields, aka help info, for the object
      @cf0925.funded_person.selected_fiscal_year = @cf0925.fiscal_year if @cf0925.fiscal_year
      redirect_to home_index_path, notice: notice
    else
      # Get the missing fields, aka help info, for the object
      @cf0925.printable?
      render :new
    end
  end

  def update
    # pp(params.as_json)
    # pp(cf0925_params.as_json)
    @cf0925 = current_user.cf0925s.find(params[:id])
    @cf0925.update(cf0925_params)
    user = @cf0925.funded_person.user
    user.assign_attributes(user_params)
    copy_parent_to_form
    copy_child_to_form

    @cf0925.allocate

    notice = "Request updated."
    notice += " Parent data updated." if user.changed?

    # I didn't need to save addresses explicitly here.
    if @cf0925.save_with_user
      @cf0925.funded_person.selected_fiscal_year = @cf0925.fiscal_year if @cf0925.fiscal_year
      redirect_to home_index_path, notice: notice
    else
      # Get the missing fields, aka help info, for the object
      @cf0925.printable?
      render :edit
    end
  end

  def destroy
    @cf0925 = current_user.cf0925s.find(params[:id])
    @cf0925.destroy

    redirect_to home_index_path, notice: "Request deleted."
  end

  private

  def catch_data_not_found
    yield
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def cf0925_params
    params
      .require(:cf0925)
      .permit(Cf0925.column_names + [])
  end

  def user_params
    # puts "PARAMS: #{params.inspect}"
    params[:cf0925][:funded_person_attributes]
      .require(:user_attributes)
      .permit(
        :id,
        :name_first,
        :name_middle,
        :name_last,
        :address,
        :city,
        :postal_code,
        :home_phone_number,
        :work_phone_number,
        :work_phone_extension
      )
  end

  def copy_parent_to_form
    @cf0925.copy_parent_to_form
  end

  def copy_child_to_form
    # puts "Before: #{@cf0925.child_in_care_of_ministry}"
    @cf0925.copy_child_to_form
    # puts "After: #{@cf0925.child_in_care_of_ministry}"
  end
end
