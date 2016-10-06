##
# Calculate the status of a child's funding in a given fiscal year.
class Status
  def initialize(funded_person, fiscal_year)
    # puts "New Status: #{funded_person.inspect} Fiscal Year: #{fiscal_year.inspect}"
    @fiscal_year = fiscal_year

    # Not really age, but age of fiscal years.
    age = fiscal_year.first.year - funded_person.start_of_first_fiscal_year.year
    # puts "AGE: #{age}"
    @allowable_funds_for_year = if age < 0
                                  0
                                elsif age < 6
                                  22_000
                                elsif age < 18
                                  6_000
                                else
                                  0
                                end

    @spent_funds = funded_person
                   .invoices_in_fiscal_year(fiscal_year)
                   .select(&:include_in_reports?)
                   .map(&:invoice_amount)
                   .reduce(0, &:+)

    @committed_funds = funded_person
                       .cf0925s_in_fiscal_year(fiscal_year)
                       .select(&:printable?)
                       .map(&:total_amount)
                       .reduce(0, &:+)

    @remaining_funds = [0, @allowable_funds_for_year - @committed_funds].max

    @spent_out_of_pocket = [0, @spent_funds - @committed_funds].max
  end

  attr_reader :allowable_funds_for_year
  attr_reader :committed_funds
  attr_reader :fiscal_year
  attr_reader :remaining_funds
  attr_reader :spent_funds
  attr_reader :spent_out_of_pocket
end
