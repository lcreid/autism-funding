##
# Calculate the status of a child's funding in a given fiscal year.
class Status
  def initialize(funded_person, fiscal_year)
    # puts "New Status: #{funded_person.inspect} Fiscal Year: #{fiscal_year.inspect}"
    @fiscal_year = fiscal_year
    @funded_person = funded_person

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

    # Spent funds should really be just that which is paid for by the Ministry.
    # This requires us to line up the invoices with RTPs.
    # The criteria would be something like: The invoice service provider
    # or supplier must match the service provider or supplier in an approved
    # RTP, and the service dates must be within the range of service dates,
    # if both are provided, and the RTP must not be all used up.
    # It might be convenient to put that into the Invoice model...
    # Or maybe not. It also makes sense that it should all be here where the
    # rules for figuring this out, reside.

    # In most cases, an invoice goes against exactly one RTP. In that case,
    # it's pretty easy to figure out what has to be paid out-of-pocket, and
    # what has been/will be paid by the ministry.
    # This still applies even if the RTP has both Part A and Part B. You just
    # have to match by the right criteria and use the right amount.
    # The complication is overlapping RTPs for the service provider or agency,
    # so that an invoice could apply to more than one RTP.
    # For invoices that go against two RTPs: One rule would be that they would
    # go against the RTP that had the most space first, and then the other if
    # there wasn't enough funding. Another rules would be to go against the
    # first RTP, by start date, then end date, then creation date.
    # Another is that it doesn't matter which they "go against." The total is
    # what's important, as long as you don't double count the invoices that
    # overlap.
    # partition_invoices.each_pair do |k, v|
    #   puts "#{k}: #{v}"
    # end

    # puts "status funded_person.invoices.size: #{funded_person.invoices.size}"
    # puts "status invoices.size: #{invoices.size}"
    @spent_out_of_pocket = invoices.sum(&:out_of_pocket)
    @spent_funds = invoices.map(&:invoice_allocations).flatten.sum(&:amount)
    # TODO: This should never be more than the allowable_funds_for_year,
    # but that check should probably be done elsewhere.
    @committed_funds = rtps.sum(&:total_amount)
    @remaining_funds = [0, @allowable_funds_for_year - @committed_funds].max
  end

  attr_reader :allowable_funds_for_year
  attr_reader :committed_funds
  attr_reader :fiscal_year
  attr_reader :funded_person
  attr_reader :remaining_funds
  attr_reader :spent_funds
  attr_reader :spent_out_of_pocket

  private

  ##
  # List of invoices that apply in this fiscal year
  def invoices
    @invoices ||= funded_person
                  .invoices_in_fiscal_year(fiscal_year)
                  .select(&:include_in_reports?)
  end

  ##
  # List of RTPs that apply in this fiscal year
  def rtps
    # puts "In rtps: funded_person #{funded_person.inspect}"
    # puts "cf0925s(#{funded_person.cf0925s.size}): " \
    # "#{funded_person.cf0925s.inspect}"
    # puts 'cf0925s_in_fiscal_year' \
    # "(#{funded_person.cf0925s_in_fiscal_year(fiscal_year).size})" \
    # ": #{funded_person.cf0925s_in_fiscal_year(fiscal_year).inspect}"
    # puts '----'
    # puts "fiscal_year: #{fiscal_year}"
    # funded_person.cf0925s.each do |rtp|
    #   puts "rtp gets fiscal year from #{rtp.method(:fiscal_year).source_location}"
    #   puts "rtp(#{rtp.fiscal_year})"
    # end
    @rtps ||= funded_person
              .cf0925s_in_fiscal_year(fiscal_year)
              .select(&:printable?)
  end
end
