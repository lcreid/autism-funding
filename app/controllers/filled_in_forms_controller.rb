class FilledInFormsController < ApplicationController
  def index
    @funded_person = FundedPerson.find(params[:funded_person_id])
  end
end
