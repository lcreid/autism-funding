module Helpers
  ##
  # Fiscal year for models that belong to a FundedPerson.
  # The model has to respond to start_date and funded_person.
  module FiscalYear
    ##
    # Return the fiscal year of the model, defined as the fiscal year of the
    # start date for service.
    def fiscal_year
      return nil unless start_date
      funded_person.fiscal_year(start_date)
    end
  end
end
