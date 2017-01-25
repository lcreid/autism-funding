class Invoice < ApplicationRecord
  include Helpers::FiscalYear

  # One record for each address
  # ----- Associations ---------------------------------------------------------
  belongs_to :funded_person
  belongs_to :cf0925, optional: true, inverse_of: :invoices
  has_many :invoice_allocations, inverse_of: :invoice, autosave: true
  has_many :cf0925s, through: :invoice_allocations, autosave: true

  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  validate :validate_check_fy_on_service_dates, on: :complete
  validate :validate_invoice_date_after_service_end, on: :complete
  validate :validate_require_an_invoicee, on: :complete
  validate :validate_service_start_before_service_end, on: :complete
  validates :invoice_amount, presence: true, on: :complete
  validates :invoice_date, presence: { in: true, message: 'Invoice date required' }, on: :complete
  #  validates :service_start, presence: { in: true, message: 'Service provider defined, no service start date' }, on: :complete, unless: 'service_provider_name.blank?'
  #  validates :service_end, presence: { in: true, message: 'Service provider defined, no service end date' }, on: :complete, unless: 'service_provider_name.blank?'

  #-----------------------------------------------------------------------------
  # ----- Callbacks ------------------------------------------------------------
  #-----------------------------------------------------------------------------

  # ----- Public Methods -------------------------------------------------------
  ##
  # Allocate one or more RTPs to the invoice.
  def allocate(rtps)
    cf0925s << rtps

    # rtps = [rtps] unless rtps.respond_to?(:each)
    # rtps.each { |rtp| rtp.invoices << self }
  end

  def include_in_reports?
    valid?(:complete)
  end

  def invoice_from
    invoice_from = []
    invoice_from << service_provider_name if service_provider_name.present?
    invoice_from << agency_name if agency_name.present?
    invoice_from << supplier_name if supplier_name.present?
    return 'No Invoicee Defined' if invoice_from.empty?
    invoice_from.join(' / ')
  end

  ##
  # Return an array of RTPs that could cover this invoice.
  # Doesn't consider how much has been spent.
  # Uses dates and matching criteria.
  def match
    # puts "In match child: #{funded_person.inspect}"
    return [] unless funded_person && funded_person.cf0925s
    # puts "ATTRIBUTES: #{attributes}"
    Invoice.match(funded_person, attributes)
  end

  ##
  # Temporarily return a value for out_of_pocket
  # FIXME: Turn this into an attribute
  attr_reader :out_of_pocket

  attr_writer :out_of_pocket

  class <<self
    # FIXME: I really question whether I needed the class method.
    def match(funded_person, params)
      # puts "match child #{funded_person.inspect} params: #{params}"
      return [] unless funded_person.cf0925s

      params = ActiveSupport::HashWithIndifferentAccess.new(params)

      agency_name = params[:agency_name]
      invoice_date = to_date(params[:invoice_date])
      service_end = to_date(params[:service_end])
      service_provider_name = params[:service_provider_name]
      service_start = to_date(params[:service_start])
      supplier_name = params[:supplier_name]

      # puts "Here is the invoice_date: #{invoice_date}"
      result = [] + funded_person.cf0925s.select(&:printable?).map do |rtp|
        # puts rtp.inspect
        if pay_provider?(rtp, service_provider_name, service_start, service_end) ||
           pay_agency?(rtp, service_provider_name, service_start, service_end)
          rtp.extend(ServiceProvider)
        elsif pay_for_supplier?(rtp, service_provider_name, invoice_date)
          rtp.extend(Supplier)
        end
      end.compact.sort
      # puts result.inspect
      result
    end

    ##
    # Determine if the RTP authorizes the invoice when the payee is the agency
    def pay_agency?(rtp, agency_name, service_start, service_end)
      service_start && service_end &&
        # (rtp.payment == 'agency' || rtp.service_provider_name.blank?) &&
        rtp.agency_name &&
        agency_name == rtp.agency_name &&
        rtp.include?(service_start..service_end)
    end

    ##
    # Determine if the RTP authorizes the invoice when the payee is the supplier
    # (actually the parent)
    def pay_for_supplier?(rtp, supplier_name, invoice_date)
      result = rtp.created_at &&
               invoice_date &&
               rtp.supplier_name &&
               supplier_name == rtp.supplier_name &&
               rtp.funded_person
                  .fiscal_year(invoice_date)
                  .include?(rtp.created_at.to_date)

      # unless result
      #   puts "supplier_name == rtp.supplier_name: #{supplier_name == rtp.supplier_name}"
      #   puts "rtp.funded_person .fiscal_year(invoice_date): #{rtp.funded_person .fiscal_year(invoice_date).inspect}"
      #   puts "rtp.created_at: #{rtp.created_at}"
      #   puts "result: #{rtp.funded_person .fiscal_year(invoice_date) .include?(rtp.created_at.to_date)}" if rtp.created_at
      # end
      # result
      # FIXME: The above needs to be fixed for the real world.
      # FIXME: It's not clear how to get a validity period for a
      # FIXME: supplier-only RTP.
    end

    ##
    # Determine if the RTP authorizes the invoice when the payee is the provider
    def pay_provider?(rtp, service_provider_name, service_start, service_end)
      service_start && service_end &&
        # (rtp.payment == 'provider' || rtp.agency_name.blank?) &&
        rtp.service_provider_name &&
        service_provider_name == rtp.service_provider_name &&
        rtp.include?(service_start..service_end)
    end

    def to_date(date)
      return nil unless date
      return date if date.is_a?(Date)
      begin
        Date.parse(date)
      rescue ArgumentError
        puts 'Rescued date conversion'
        nil
      end
    end
  end

  ##
  # Return all the possible payees for an invoice.
  def possible_payees
    funded_person.possible_payees
  end

  # Return a range of the service start and end
  def service_period
    Range.new(service_start, service_end) if service_start && service_end
  end

  def start_date
    st = service_end
    st = invoice_date unless invoice_date.blank?
    st = service_start unless service_start.blank?
    st
  end #-- start_date --

  def validate_check_fy_on_service_dates
    #-- run validation only if both dates are present
    return if service_start.blank? || service_end.blank?

    #-- Check that the invoice date is later than the service end date
    res = funded_person.fiscal_year(service_start).<=>funded_person.fiscal_year(service_end)
    errors.add(:service_end, 'must be in the same fiscal year as service start') unless res == 0
  end #-- validate_check_fy_on_service_dates --

  def validate_invoice_date_after_service_end
    #-- run validation only if both dates are present
    return if invoice_date.blank? || service_end.blank?

    #-- Check that the invoice date is later than the service end date
    errors.add(:invoice_date, 'should not be earlier than the service end') if
      service_end > invoice_date
  end #-- validate_invoice_date_after_service_end --

  def validate_require_an_invoicee
    #-- error if there is not at least one supplier, servicer provider or agency name
    if service_provider_name.blank? && supplier_name.blank? && agency_name.blank?
      errors.add(:service_provider_name, 'must provide at least one of service provider, supplier or agency name')
    end
  end #-- validate_require_an_invoicee --

  #  def validate_service_dates_present_if_service_provider
  #    #-- run validation only if service_provider_name is present
  #    return if service_provider_name.blank?
  #
  #    #-- Check that the invoice date is later than the service end date
  #    errors.add(:invoice_date, 'should not be earlier than the service end`') if
  #      service_end < invoice_date
  #  end

  def validate_service_start_before_service_end
    #-- run validation only if both dates are present
    return if service_start.blank? || service_end.blank?

    #-- Check that the service end date is later than the service start date
    errors.add(:service_end, 'must be after service start date') if
      service_end < service_start
  end #-- validate_service_start_before_service_end --

  #-----------------------------------------------------------------------------
  # ----- Protected Methods ----------------------------------------------------

  #  protected

  #-----------------------------------------------------------------------------

  # ----- Private Methods ------------------------------------------------------
  #-----------------------------------------------------------------------------
  private
end
