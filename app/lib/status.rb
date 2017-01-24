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

    # puts "RTPs(#{rtps.size}): #{rtps.inspect}"
    @spent_out_of_pocket = invoices
                           .select { |x| !invoice_has_rtp?(x) }
                           .map(&:invoice_amount)
                           .sum

    @spent_out_of_pocket += rtps.map(&:out_of_pocket).sum

    @spent_funds = rtps.map(&:spent_funds).sum

    @committed_funds = rtps.map(&:total_amount).reduce(0, &:+)

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
    # The invoices should have been allocated to RTPs when they were entered.
  end

  ##
  # An invoice has an RTP if there is a Cf0925 attached to the invoice.
  def invoice_has_rtp?(invoice)
    invoice.cf0925s.present?
  end

  ##
  # List of invoices that apply in this fiscal year
  def invoices
    @invoices ||= @funded_person
                  .invoices_in_fiscal_year(fiscal_year)
                  .select(&:include_in_reports?)
    # .sort_by(&:fiscal_year)
  end

  ##
  # Partition invoices into the RTPs that could pay for them.
  # Returns hash where key is RTP and value is array of invoices.
  def partition_invoices
    a = {}
    rtps.each do |rtp|
      a[rtp] = invoices.select { |x| rtp_has_invoice?(rtp, x) }
    end
    a
  end

  # ##
  # # Determine if the RTP authorizes the invoice when the payee is agency
  # def pay_agency?(invoice, rtp)
  #   rtp.payment == 'agency' &&
  #     (invoice.agency_name || rtp.agency_name) &&
  #     invoice.agency_name == rtp.agency_name &&
  #     rtp.include?(invoice.service_period)
  # end
  #
  # ##
  # # Determine if the RTP authorizes the invoice when the payee is the supplier
  # # (actually the parent)
  # def pay_for_supplier?(invoice, rtp)
  #   (invoice.supplier_name || rtp.supplier_name) &&
  #     invoice.supplier_name == rtp.supplier_name &&
  #     rtp.fiscal_year.include?(invoice.invoice_date)
  # end
  #
  # ##
  # # Determine if the RTP authorizes the invoice when the payee is the provider
  # def pay_provider?(invoice, rtp)
  #   rtp.payment == 'provider' &&
  #     (invoice.service_provider_name || rtp.service_provider_name) &&
  #     invoice.service_provider_name == rtp.service_provider_name &&
  #     rtp.include?(invoice.service_period)
  # end

  def rtp_has_invoice?(rtp, invoice)
    pay_provider?(invoice, rtp) ||
      pay_agency?(invoice, rtp) ||
      pay_for_supplier?(invoice, rtp)
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
