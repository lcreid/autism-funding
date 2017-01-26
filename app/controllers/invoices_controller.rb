class InvoicesController < ApplicationController
  def new
    @invoice = Invoice.new
    @invoice.funded_person =
      @funded_person =
        FundedPerson.find(params[:funded_person_id])
    # @url = funded_person_invoices_path params[:funded_person_id]
    #    @invoice.funded_person = @funded_person =FundedPerson.find(params[:funded_person_id])
    #  @invoice.cf0925 = @cf0925 = Cf0925.find(params[:cf0925_id])
  end

  def index
    @funded_person = FundedPerson.find(params[:funded_person_id])
    @invoices = Invoice.where("funded_person_id = #{@funded_person.id}")
    @title = "Invoices for #{@funded_person.my_name}"
    @subtitle = "#{@invoices.size} Invoices"
  end

  def edit
    # TODO: add test cases that this works for attaching the RTP to the invoice
    # @url = invoice_path params[:id]

    @invoice = Invoice.find(params[:id])
    @invoice.valid?(:complete)
    # @funded_person = @invoice.funded_person
  end

  def update
    # TODO: add test cases that this works for attaching the RTP to the invoice
    @invoice = Invoice.find(params[:id])
    logger.debug { "******Service Provider:  #{@invoice.service_provider_name}" }
    @invoice.update(invoice_params)
    @invoice.funded_person.selected_fiscal_year = @invoice.funded_person.fiscal_year(@invoice.start_date)
    #    redirect_to funded_person_invoices_path(@invoice.funded_person_id)
    redirect_to root_path, notice: 'Invoice updated.'
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @funded_person = @invoice.funded_person
    @invoice.destroy
    # redirect_to funded_person_invoices_path(@funded_person.id)
    redirect_to root_path
  end

  def create
    @invoice = Invoice.new
    @invoice.funded_person = FundedPerson.find(params[:funded_person_id])
    logger.debug { "**** invoices_controller safe params: #{invoice_params.inspect}" }
    if @invoice.update(invoice_params)
      # puts @invoice.inspect
      @invoice.funded_person.selected_fiscal_year = @invoice.funded_person.fiscal_year(@invoice.start_date)
      #      redirect_to funded_person_invoices_path(@invoice.funded_person_id)
      redirect_to root_path, notice: 'Invoice saved.'
    else
      render 'new'
    end
    @msg = 'phil'
  end

  def rtps
    # puts 'IN RTPS'
    # Remember that this could be called from new, so you don't enen have an
    # invoice yet. So make a throw-away invoice.

    # TODO: Review how this is done. I think I can do better.

    @invoice = Invoice.new
    @invoice.assign_attributes(convert_search_params_to_create_params)
    # FIXME: I can craft a URL to get anyone's info.
    @invoice.funded_person =
      @funded_person = FundedPerson.find(params[:funded_person_id])

    # puts "TEMPORARY INVOICE: #{@invoice.inspect}"

    @invoice.allocate(@invoice.match)
    helpers.bootstrap_form_for([@funded_person, @invoice],
                               builder: AutismFundingFormBuilder) do |f|
      # puts "PARTIAL: #{render_to_string(partial: 'invoice_allocation_wrapper',
      #                                   locals: {
      #                                     collection: @invoice.allocate(@invoice.match),
      #                                     invoice_form: f
      #                                   },
      #                                   layout: !request.xhr?)}"
      render partial: 'invoice_allocation_wrapper',
             locals: { invoice_form: f },
             layout: !request.xhr?
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:cf0925_id,
                                    :invoice_date,
                                    :service_start,
                                    :service_end,
                                    :service_provider_name,
                                    :agency_name,
                                    :supplier_name,
                                    :invoice_amount,
                                    :invoice_reference,
                                    :notes,
                                    invoice_allocations_attributes: [
                                      :cf0925_id,
                                      :invoice_id,
                                      :cf0925_type,
                                      :amount
                                    ])
  end

  def convert_search_params_to_create_params
    # { invoice: params }.require(:invoice)
    params.permit(:cf0925_id,
                  :invoice_date,
                  :service_start,
                  :service_end,
                  :service_provider_name,
                  :agency_name,
                  :supplier_name,
                  :funded_person_id)
  end
end
