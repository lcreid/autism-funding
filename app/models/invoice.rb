class Invoice < ApplicationRecord
  include Helpers::FiscalYear

  # One record for each address
  # ----- Associations ---------------------------------------------------------
  belongs_to :funded_person
  # belongs_to :cf0925, optional: true, inverse_of: :invoices
  has_many :invoice_allocations, inverse_of: :invoice, dependent: :destroy
  accepts_nested_attributes_for :invoice_allocations, allow_destroy: true
  has_many :cf0925s, through: :invoice_allocations, autosave: true

  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  # validate :validate_check_fy_on_service_dates, on: :complete
  # validate :validate_invoice_date_after_service_end, on: :complete
  validates :invoice_amount, presence: true, on: :complete
  validates :invoice_from, presence: true, on: :complete
  validate :validate_dates, on: :complete
  # validate :validate_service_start_before_service_end, on: :complete
  # validates :invoice_date, presence: { in: true, message: 'Invoice date required' }, on: :complete
  #  validates :service_start, presence: { in: true, message: 'Service provider defined, no service start date' }, on: :complete, unless: 'service_provider_name.blank?'
  #  validates :service_end, presence: { in: true, message: 'Service provider defined, no service end date' }, on: :complete, unless: 'service_provider_name.blank?'

  #-----------------------------------------------------------------------------
  # ----- Callbacks ------------------------------------------------------------
  #-----------------------------------------------------------------------------

  # ----- Public Methods -------------------------------------------------------
  ##
  # Allocate one or more RTPs to the invoice.
  def allocate(matches)
    matches = [matches] unless matches.respond_to?(:each)
    #  puts "allocate: matches #{matches.size}"
    incoming_set = matches.to_set
    old_set = invoice_allocations.to_set
    to_be_deleted_set = old_set - incoming_set
    # old_set = invoice_allocations.map do |ia|
    #   Match.new(ia)
    # end.to_set

    # puts "allocate: old_set #{old_set.map(&:object_id)}"
    # puts "allocate: incoming_set #{incoming_set.map(&:object_id)}"
    # puts "allocate: old_set + incoming_set #{(old_set + incoming_set).map(&:object_id)}"
    # puts "allocate: to_be_deleted_set #{(to_be_deleted_set).map(&:object_id)}"
    # puts "allocate: to_be_deleted_set classes #{(to_be_deleted_set).map(&:class)}"

    # puts "allocate: to_be_deleted_set #{(to_be_deleted_set).to_a}"
    invoice_allocations.delete(to_be_deleted_set.to_a).each do |ia|
      ia.cf0925.invoice_allocations.delete(ia)
    end
    # puts "allocate: invoice_allocations #{invoice_allocations.map(&:object_id)}"

    new_set = incoming_set - old_set
    # puts "----------------------------"
    # puts "invoice#allocate #{__LINE__}: For Invoice object_id: #{self.object_id} (#{self.invoice_amount})"
    # incoming_set.each {|s| puts " incoming: object_id: #{s.object_id} rtp id: #{s.cf0925.object_id} rtp db id: #{s.cf0925.id}  type: #{s.cf0925_type}"}
    # old_set.each {|s| puts " old: object_id: #{s.object_id} rtp id: #{s.cf0925.object_id}  rtp db id: #{s.cf0925.id}  type:  #{s.cf0925_type}"}
    # new_set.each {|s| puts " new: object_id: #{s.object_id} rtp id: #{s.cf0925.object_id}  rtp db id: #{s.cf0925.id}  type: #{s.cf0925_type}"}
    # (old_set - incoming_set).each {|s| puts " old - incoming: object_id: #{s.object_id} rtp id: #{s.cf0925.object_id}  rtp db id: #{s.cf0925.id}  type: #{s.cf0925_type}"}
    #    puts "allocate: incoming_set #{new_set.map(&:object_id)}"
    # puts "----------------------------"
    new_set.map do |match|
      connect(match.cf0925, match.cf0925_type)
    end

    # puts "allocate: result #{invoice_allocations.map(&:cf0925).map(&:object_id)}"
    # puts "allocate: result.inspect #{invoice_allocations.inspect}"

    invoice_allocations
  end

  ##
  # Put an invoice allocation between a cf0925 and an invoice.
  # Public so it can be used to set up test data.
  def connect(cf0925, type, amount = 0)
    invoice_allocations <<
      (ia = cf0925.invoice_allocations.build(cf0925_type: type, amount: amount))
    ia
  end

  def include_in_reports?
    valid?(:complete)
  end

  # ##
  # # Convert the three old invoice fields to the new unified field.
  # def invoice_from
  #   invoice_from = []
  #   invoice_from << service_provider_name if service_provider_name.present?
  #   invoice_from << agency_name if agency_name.present?
  #   invoice_from << supplier_name if supplier_name.present?
  #   return 'No Invoicee Defined' if invoice_from.empty?
  #   invoice_from.join(' / ')
  # end

  ##
  # Return an array of RTPs that could cover this invoice.
  # Doesn't consider how much has been spent.
  # Uses dates and matching criteria.
  def match
    # puts "In match child: #{funded_person.inspect}"
    return [] unless funded_person && funded_person.cf0925s
    # puts "ATTRIBUTES: #{attributes}"
    funded_person.match(attributes)
  end

  ##
  # Calculate out of pocket expenses for this invoice.
  def out_of_pocket
    return 0 unless invoice_amount && invoice_allocations
    # puts "out_of_pocket invoice_amount: #{invoice_amount}"
    # invoice_allocations
    #   .select(&:amount)
    #   .each { |ia| puts "out_of_pocket: #{ia.cf0925}, #{ia.invoice}, #{ia.cf0925_type}, #{ia.amount}" }
    [invoice_amount - invoice_allocations.select(&:amount).sum(&:amount), 0].max
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

  def validate_dates
    if service_start.blank? && invoice_date.blank? && service_end.blank?
      errors.add(:service_start, 'must supply at least one date')
      errors.add(:service_end, 'must supply at least one date')
      errors.add(:invoice_date, 'must supply at least one date')
    end

    unless service_start.blank? || service_end.blank? || service_end >= service_start
      errors.add(:service_end, 'service end cannot be earlier than service start')
    end

    unless service_start.blank? || service_end.blank? || funded_person.fiscal_year(service_start) == funded_person.fiscal_year(service_end)
      errors.add(:service_end, 'must be in the same fiscal year as service start')
    end
  end

  def xxvalidate_check_fy_on_service_dates
    #-- run validation only if both dates are present
    return if service_start.blank? || service_end.blank?

    #-- Check that the invoice date is later than the service end date
    res = funded_person.fiscal_year(service_start).<=>funded_person.fiscal_year(service_end)
    errors.add(:service_end, 'must be in the same fiscal year as service start') unless res == 0
  end #-- validate_check_fy_on_service_dates --

  def xxvalidate_invoice_date_after_service_end
    #-- run validation only if both dates are present
    return if invoice_date.blank? || service_end.blank?

    #-- Check that the invoice date is later than the service end date
    errors.add(:invoice_date, 'should not be earlier than the service end') if
      service_end > invoice_date
  end #-- validate_invoice_date_after_service_end --

  #  def validate_service_dates_present_if_service_provider
  #    #-- run validation only if service_provider_name is present
  #    return if service_provider_name.blank?
  #
  #    #-- Check that the invoice date is later than the service end date
  #    errors.add(:invoice_date, 'should not be earlier than the service end`') if
  #      service_end < invoice_date
  #  end

  def xxvalidate_service_start_before_service_end
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
