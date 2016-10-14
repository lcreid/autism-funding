class InvoicesController < ApplicationController
  def new

    @invoice = Invoice.new
    @url = funded_person_invoices_path (params[:funded_person_id])
#    @invoice.funded_person = @funded_person =FundedPerson.find(params[:funded_person_id])
  #  @invoice.cf0925 = @cf0925 = Cf0925.find(params[:cf0925_id])
  end
  def index
    @funded_person =FundedPerson.find(params[:funded_person_id])
    @invoices = Invoice.where("funded_person_id = #{@funded_person.id}")
    @title = "Invoices for #{@funded_person.my_name}"
    @subtitle = "#{@invoices.size} Invoices"
  end

  def edit
    @url = invoice_path (params[:id])

    @invoice = Invoice.find(params[:id])
    @invoice.valid?(:complete)
    @funded_person = @invoice.funded_person
  end

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.update(invoice_params)
    ## TODO Save the fiscal year of the updated invoice in the funded person's preferences
#    redirect_to funded_person_invoices_path(@invoice.funded_person_id)
    redirect_to root_path
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @funded_person = @invoice.funded_person
    @invoice.destroy
    redirect_to funded_person_invoices_path(@funded_person.id)
  end

  def create
    @invoice = Invoice.new
    @invoice.funded_person = FundedPerson.find(params[:funded_person_id])
    if @invoice.update(invoice_params)
#      redirect_to funded_person_invoices_path(@invoice.funded_person_id)
      ## TODO Save the fiscal year of the created invoice in the funded person's preferences
      redirect_to root_path
    else
      render 'new'
    end
    @msg = "phil"
  end


  private

  def invoice_params
    params.require(:invoice).permit(:invoice_date, :service_start, :service_end, :service_provider_name, :agency_name, :supplier_name, :invoice_amount, :invoice_reference, :notes)
  end

end
