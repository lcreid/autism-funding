module Helpers
  ##
  # Fiscal year for models that belong to a FundedPerson.
  # The model has to respond to start_date and funded_person.
  module FiscalYear
    ##
    # Return the fiscal year of the model, defined as the fiscal year of the
    # start date for service.
    def fiscal_year
      #-- if no start_date defined, then return default of the FY of now
      # TODO: This should probably give the fiscal year of the record
      # creation date, or Time.new if the record hasn't been saved yet.
      # Then we can fix the Supplier module methods to use fiscal_year.
      return funded_person.fiscal_year(start_date) if start_date
      puts "funded_person: #{funded_person.inspect} getting fy from now"
      funded_person.fiscal_year(Time.new)

      #-- start_date is defined, the funded_person part will determine the FY
      #    based on the dob and start_date
    end

    def in_fiscal_year?(fy)
      fy.include?(fiscal_year)
    end
  end
end
