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
    invoice_list = funded_person
                   .invoices_in_fiscal_year(fiscal_year)
                   .select(&:include_in_reports?)
                   .sort_by(&:fiscal_year)

    @spent_funds = invoice_list
                   .select { |x| invoice_has_rtp?(x) }
                   .map(&:invoice_amount)
                   .reduce(0, &:+)

    @spent_out_of_pocket = invoice_list
                           .select { |x| !invoice_has_rtp?(x) }
                           .map(&:invoice_amount)
                           .reduce(0, &:+)

    @committed_funds = funded_person
                       .cf0925s_in_fiscal_year(fiscal_year)
                       .select(&:printable?)
                       .map(&:total_amount)
                       .reduce(0, &:+)

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
  # Allocate invoices to RTPs
  def allocate_invoices
    # Only invoices and RTPs in the requested fiscal year.
    # Oldest invoice first
    # The oldest RTP that covers the invoice, and that has room, is the one.
    # Any left-over goes to out-of-pocket
  end

  ##
  # If the rtp is payable to service provider,
  # the service provider names must match
  # If the rtp is payable to the agency,
  # the agency names must match.
  # And the date range has to be right.
  # If there's a supplier name on the invoice,
  # the supplier names must match,
  # and the invoice date has to be in the fiscal year of the RTP.
  def invoice_has_rtp?(invoice)
    # puts "#{@funded_person} has " \
    # "#{@funded_person.cf0925s_in_fiscal_year(@fiscal_year).size} RTPs."
    ret_val = @funded_person.cf0925s_in_fiscal_year(@fiscal_year)
                            .select(&:printable?)
                            .find do |rtp|
      # puts "RTP: #{rtp.payment}, " \
      #      "#{rtp.service_provider_name}, " \
      #      "#{invoice.service_provider_name}, " \
      #      "#{rtp.agency_name}, " \
      #      "#{invoice.agency_name}, " \
      #      "#{Range.new(rtp.service_provider_service_start, rtp.service_provider_service_end)} " \
      #      "#{invoice.service_period}, " \
      #      "#{rtp.fiscal_year.inspect}, " \
      #      "#{invoice.invoice_date}"

      rtp.payment == 'provider' &&
        (invoice.service_provider_name || rtp.service_provider_name) &&
        invoice.service_provider_name == rtp.service_provider_name &&
        rtp.include?(invoice.service_period) ||
        rtp.payment == 'agency' &&
          (invoice.agency_name || rtp.agency_name) &&
          invoice.agency_name == rtp.agency_name &&
          rtp.include?(invoice.service_period) ||
        (invoice.supplier_name || rtp.supplier_name) &&
          invoice.supplier_name == rtp.supplier_name &&
          rtp.fiscal_year.include?(invoice.invoice_date)
    end

    # puts "invoice_has_rtp? #{!!ret_val}, #{!ret_val}"
    ret_val
  end
end
