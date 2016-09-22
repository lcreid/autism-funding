class InvoicesController < ApplicationController
  def new

    @invoice = Invoice.new
    @invoice.funded_person = @funded_person =FundedPerson.find(params[:funded_person_id])
  #  @invoice.cf0925 = @cf0925 = Cf0925.find(params[:cf0925_id])
  end
end
