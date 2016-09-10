class FilledInFormsController < ApplicationController
  def index
    @funded_person = FundedPerson.find(params[:funded_person_id])
    @filled_in_forms = Cf0925.find_by(funded_person: @funded_person)
  end
end
