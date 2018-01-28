##
# Request to pay form for BC
# TODO: The second page (instructions) for the CF_0925 says to put the date
# of training or travel on the details lines. Doesn't say how to give date
# for a purchase.
class Cf0925 < ApplicationRecord
  include Formatters
  include ActionView::Helpers::NumberHelper

  belongs_to :form
  belongs_to :funded_person, inverse_of: :cf0925s
  accepts_nested_attributes_for :funded_person
  has_many :invoice_allocations,
    inverse_of: :cf0925,
    autosave: true,
    dependent: :destroy
  has_many :invoices, through: :invoice_allocations, autosave: true

  class << self
    def part_a_required_attributes
      [
        # :agency_name,
        # :payment,
        :service_provider_postal_code,
        :service_provider_address,
        :service_provider_city,
        :service_provider_phone,
        # :service_provider_name,
        :service_provider_service_1,
        # :service_provider_service_2,
        # :service_provider_service_3,
        :service_provider_service_amount,
        :service_provider_service_end,
        :service_provider_service_fee,
        :service_provider_service_hour,
        :service_provider_service_start
      ]
    end

    def part_b_required_attributes
      [
        :supplier_address,
        :supplier_city,
        # :supplier_contact_person,
        :supplier_name,
        :supplier_phone,
        :supplier_postal_code,
        :item_cost_1,
        # :item_cost_2,
        # :item_cost_3,
        :item_desp_1,
        # :item_desp_2,
        # :item_desp_3
        :part_b_fiscal_year
      ]
    end
  end

  before_validation :set_form, :copy_child_to_form, :copy_parent_to_form

  validate :adjust_all_invoice_allocations

  with_options on: :printable do
    validates :child_dob,
      :child_first_name,
      :child_last_name,
      presence: true
    validates :child_in_care_of_ministry,
      inclusion: { in: [true, false] }

    validates :work_phone,
      presence: true,
      unless: ->(x) { x.home_phone.present? }
    validates :home_phone,
      presence: true,
      unless: ->(x) { x.work_phone.present? }

    validate unless: ->(rtp) { rtp.filling_in_part_a? || rtp.filling_in_part_b? } do
      errors.add(:base, "Fill in Part A or Part B or both.")
    end

    with_options if: :filling_in_part_a? do
      validates(*Cf0925.part_a_required_attributes,
        presence: true)
      validate :start_date_before_end_date
      validate :start_and_end_dates_in_same_fiscal_year
      validates :agency_name,
        presence: true,
        unless: ->(x) { x.service_provider_name.present? }
      validates :service_provider_name,
        presence: true,
        unless: ->(x) { x.agency_name.present? }
      validates :payment,
        presence: {
          message: "please choose either service provider or agency"
        },
        unless: lambda { |x|
          x.agency_name.blank? || x.service_provider_name.blank?
        }
    end

    with_options if: :filling_in_part_b? do
      validates *Cf0925.part_b_required_attributes, presence: true
      validate :part_b_fiscal_year_valid_for_child
    end
  end

  ##
  # TODO: This doesn't give a reliable sort, which might be needed in some
  # places.
  def <=>(other)
    service_period.begin <=> other.service_period.begin ||
      service_period.end <=> other.service_period.end
  end

  ##
  # If the value of part a or part b changes, check all the invoice allocations
  # to make sure they don't exceed the authorized value on the RTP.
  def adjust_all_invoice_allocations
    if changed_attributes[:service_provider_service_amount]
      # puts "CHANGED: invoice_allocations.size: #{invoice_allocations.size}"
      adjust_invoice_allocations("ServiceProvider")
    end

    if changed_attributes[:item_cost_1] ||
       changed_attributes[:item_cost_2] ||
       changed_attributes[:item_cost_3]
      # puts "CHANGED: invoice_allocations.size: #{invoice_allocations.size}"
      adjust_invoice_allocations("Supplier")
    end
  end

  def allocate
    funded_person.invoices.each do |inv|
      # puts "inv.include_in_reports?: #{inv.include_in_reports?}"
      matches = inv.match
      # puts "cf0925_allocate #{__LINE__}: Matches: #{matches.size} inv object id: #{inv.object_id} inv id: #{inv.id}"
      # matches.each { |m| puts "  match id: #{m.object_id} rtp id: #{m.cf0925.object_id} type #{m.cf0925_type}" }
      # puts '  ..........................'
      # puts "cf0925#allocate #{__LINE__}: "
      # InvoiceAllocation.all.each { |ia| puts ia.inspect.to_s }

      inv.allocate(matches)

      # puts "cf0925#allocate #{__LINE__}: "
      # InvoiceAllocation.all.each { |ia| puts ia.inspect.to_s }
      # puts "cf0925_allocate #{__LINE__}:  rtp.invoice_allocations.size #{invoice_allocations.size}"
      # inv.save
      # puts "cf0925_allocate #{__LINE__}: Invoice allocations #{inv.invoice_allocations.size}"
      # puts "cf0925_allocate #{__LINE__}: DBbase InvoiceAllocation.size #{InvoiceAllocation.all.size}"
    end
    self # so we can chain methods.
  end

  def client_pdf_file_name
    child_last_name + "-" +
      child_first_name + "-" +
      id.to_s +
      ".pdf"
  end

  def copy_parent_to_form
    if user
      self.parent_last_name = user.name_last
      self.parent_first_name = user.name_first
      self.parent_middle_name = user.name_middle
      # puts "In copy_parent_to_form home phone: #{user.home_phone.full_number}"
      #      self.home_phone = user.home_phone.full_number if user.home_phone
      self.home_phone = user.home_phone_number
      self.work_phone = user.work_phone_number
      # 20161126 - Phil removed the following:
      # if user.address
      # self.parent_address = user.address.address_line_1
      # self.parent_city = user.address.city
      # self.parent_postal_code = user.address.postal_code
      # end
      # 20161126 - Phil added to use the address attribute of user
      self.parent_address = user.address
      self.parent_city = user.city
      self.parent_postal_code = user.postal_code
      #--------------------------------------------------------------
    end
  end

  def copy_child_to_form
    # puts "Before: #{child_dob}"
    if funded_person
      self.child_last_name = funded_person.name_last
      self.child_first_name = funded_person.name_first
      self.child_middle_name = funded_person.name_middle
      self.child_dob = funded_person.my_dob
      self.child_in_care_of_ministry = funded_person.child_in_care_of_ministry
    end
    # puts "After: #{child_dob}"
  end

  # So I can use the object as a key in a hash (see status.rb)
  # The default behaviour of ActiveRecord::Core:== is needed for a number
  # of test cases. If we override it, we need to at least preserve the default
  # behaviour for objects without an id defined (i.e. unsaved objects).
  # def ==(other)
  #   # puts "== #{respond_to?(cf0925_type) && cf0925_type != other.cf0925_type}"
  #   # puts "== self #{cf0925_type} other #{other.cf0925_type}" if respond_to?(cf0925_type)
  #   return false if respond_to?(cf0925_type) && cf0925_type != other.cf0925_type
  #   (attributes.reject { |k, _v| %w(created_at updated_at).include?(k) })
  #     .each_pair
  #     .reduce { |a, e| a && e[1] == other.send(e[0]) }
  # end
  #
  # alias eql? ==

  def fiscal_year
    if service_provider_service_start
      funded_person.fiscal_year(service_provider_service_start)
    elsif service_provider_service_end
      funded_person.fiscal_year(service_provider_service_end)
    elsif part_b_fiscal_year
      part_b_fiscal_year
    end
  end

  def format_date(date)
    date
  end

  def filling_in_part_a?
    # answer =
    agency_name.present? ||
      # payment.present? ||
      service_provider_postal_code.present? ||
      service_provider_address.present? ||
      service_provider_city.present? ||
      service_provider_phone.present? ||
      service_provider_name.present? ||
      service_provider_service_1.present? ||
      service_provider_service_2.present? ||
      service_provider_service_3.present? ||
      service_provider_service_amount.present? ||
      service_provider_service_end.present? ||
      service_provider_service_fee.present? ||
      # service_provider_service_hour.present? ||
      service_provider_service_start.present?
    #
    # puts "Answer: #{answer}, Start: #{service_provider_service_start}" \
    # ", End: #{service_provider_service_end}"
    # answer
  end

  def filling_in_part_b?
    supplier_address.present? ||
      supplier_city.present? ||
      supplier_contact_person.present? ||
      supplier_name.present? ||
      supplier_phone.present? ||
      supplier_postal_code.present? ||
      # Don't include part_b_fiscal_year here so we can default it to the
      # current year.
      # part_b_fiscal_year.present? ||
      item_cost_1.present? ||
      item_cost_2.present? ||
      item_cost_3.present? ||
      item_desp_1.present? ||
      item_desp_2.present? ||
      item_desp_3.present?
  end

  def generate_pdf
    # begin
    pdftk = PdfForms.new("/usr/bin/pdftk")
    # puts "Home: #{home_phone}"
    # puts "Work: #{work_phone}"
    # puts "Provider: #{service_provider_phone}"
    # puts "Supplier: #{supplier_phone}"
    home_phone_parts = match_phone_number(home_phone)
    work_phone_parts = match_phone_number(work_phone)
    service_provider_phone_parts = match_phone_number(service_provider_phone)
    supplier_phone_parts = match_phone_number(supplier_phone)
    pdftk.fill_form(form.file_name,
      pdf_output_file,
      {
        parent_lst_name: parent_last_name,
        chld_lst_name: child_last_name,
        parent_Address: parent_address,
        sp_name: service_provider_name,
        agency_name: agency_name,
        address_SP: service_provider_address,
        SP_serv_1: service_provider_service_1,
        SP_serv_2: service_provider_service_2,
        SP_serv_3: service_provider_service_3,
        sup_name: supplier_name,
        adrs_sup: supplier_address,
        item_desp_1: item_desp_1,
        item_cost_1:
          formatted_currency(item_cost_1),
        item_cost_2:
          formatted_currency(item_cost_2),
        item_total:
          formatted_currency(item_total),
        item_cost_3:
          formatted_currency(item_cost_3),
        item_desp_2: item_desp_2,
        item_desp_3: item_desp_3,
        cnt_person: supplier_contact_person,
        city_sup: supplier_city,
        PC_sup: format_postal_code(supplier_postal_code),
        city_SP: service_provider_city,
        PC_SP: format_postal_code(service_provider_postal_code),
        SP_serv_start:
          format_date(service_provider_service_start),
        SP_serv_fee:
          formatted_currency(service_provider_service_fee),
        SP_serv_hr: service_provider_service_hour,
        SP_serv_amt:
          formatted_currency(service_provider_service_amount),
        SP_serv_end: format_date(service_provider_service_end),
        ph_area_SP:
          formatted_area_code(service_provider_phone_parts),
        sup_area_ph: formatted_area_code(supplier_phone_parts),
        phn_SP:
          formatted_phone_number(service_provider_phone_parts),
        sup_ph: formatted_phone_number(supplier_phone_parts),
        parent_city: parent_city,
        parent_PC: format_postal_code(parent_postal_code),
        parent_fst_name: parent_first_name,
        chld_fst_name: child_first_name,
        parent_mid_name: parent_middle_name,
        chld_mid_name: child_middle_name,
        hm_phn_area: formatted_area_code(home_phone_parts),
        hm_phn: formatted_phone_number(home_phone_parts),
        chld_DOB: format_date(child_dob),
        chld_yn: translate_care_of_ministry_to_pdf_field, # This comes from radio buttons
        Payment: translate_payment_to_pdf_field, # This comes from radio buttons
        wrk_phn_area: formatted_area_code(work_phone_parts),
        wrk_phn: formatted_phone_number(work_phone_parts)
      },
      flatten: true)
    # rescue PdfForms::PdftkError => e
    # puts e.to_s
    # return false
    # end
    true
  end

  # So I can use the object as a key in a hash (see status.rb)
  def hash
    attributes.values.reduce { |a, e| a.to_s + e.to_s }.hash
  end

  ##
  # Try all the ways to see if the cf0925 is in a fiscal year.
  def in_fiscal_year?(fy)
    fy = FiscalYear.new(fy) unless fy.is_a?(FiscalYear)
    fy.include?(fiscal_year)
    # if service_provider_service_start && service_provider_service_end
    #   fy.include? FiscalYear.new(service_provider_service_start..service_provider_service_end)
    # elsif part_b_fiscal_year
    #   fy.include? part_b_fiscal_year
    # else
    #   false
    # end
  end

  ##
  # Return true if the date  or date range passed in is within the service
  # dates of the Cf0925.
  def include?(range)
    # puts "RTP range: #{service_period}"
    # puts "Invoice (other) range: #{range}"
    service_period.include?(range) # rubocop:disable Performance/RangeInclude
  end

  def item_cost_1=(value)
    super number_clean(value)
  end

  def item_cost_2=(value)
    super number_clean(value)
  end

  def item_cost_3=(value)
    super number_clean(value)
  end

  def item_total
    return nil unless item_cost_1 || item_cost_2 || item_cost_3
    (item_cost_1 || 0) +
      (item_cost_2 || 0) +
      (item_cost_3 || 0)
  end

  def part_b_fiscal_year
    funded_person.fiscal_year(super)
  end

  # TODO: Think about this. Playing games with the value here made the
  # select box hard to work with. I couldn't just use the defaults, and have
  # to manually call to_s to make things work.
  # TODO: I should be able to define this as an attribute of type FiscalYear
  def part_b_fiscal_year=(value)
    if value.is_a?(FiscalYear)
      super value.to_s
    else
      super
    end
  end

  def part_b_fiscal_year_after_child_turns_18?
    funded_person.after_last_fiscal_year?(part_b_fiscal_year)
  end

  def part_b_fiscal_year_before_birth?
    funded_person.before_first_fiscal_year?(part_b_fiscal_year)
  end

  ##
  # Make sure fiscal year is after child is born and before it turns 18
  def part_b_fiscal_year_valid_for_child
    return if part_b_fiscal_year.blank?

    if part_b_fiscal_year_before_birth?
      errors.add(:part_b_fiscal_year, "must be after child is born")
    end

    if part_b_fiscal_year_after_child_turns_18?
      errors.add(:part_b_fiscal_year, "must be before child turns 18")
    end
  end

  ##
  # Determine if Part A of RTP authorizes the invoice
  def pay_part_a?(invoice_from, invoice_date, service_start, service_end)
    date_for_comparison = if service_start && service_end
                            (service_start..service_end)
                          elsif service_start
                            service_start..service_start
                          elsif service_end
                            service_end..service_end
                          else
                            invoice_date
                          end

    (service_provider_name &&
        invoice_from == service_provider_name ||
        agency_name &&
        invoice_from == agency_name) &&
      include?(date_for_comparison)
  end

  ##
  # Determine if the RTP authorizes the invoice when the payee is the supplier
  # (actually the parent)
  def pay_part_b?(invoice_from, invoice_date, service_start, service_end)
    # result =
    # puts "part_b_fiscal_year.class #{part_b_fiscal_year.class}"
    date_for_comparison = if invoice_date
                            invoice_date
                          elsif service_start && service_end
                            service_start..service_end
                          elsif service_start.nil?
                            service_end
                          else
                            service_start
                          end

    result = supplier_name &&
             invoice_from == supplier_name &&
             part_b_fiscal_year.present? &&
             date_for_comparison &&
             part_b_fiscal_year.include?(date_for_comparison)

    # unless result
    # puts "invoice_from, supplier_name: #{invoice_from},  #{supplier_name}"
    # puts "invoice_from == supplier_name: #{invoice_from == supplier_name}"
    # puts "part_b_fiscal_year: #{part_b_fiscal_year}, invoice_date: #{invoice_date}"
    # end
    result
  end

  def pdf_output_file
    "/tmp/cf0925_#{id}.pdf"
  end

  ##
  # Pull the info from the user and the funded_person into the Cf0925 instance
  def populate
    copy_parent_to_form
    copy_child_to_form
  end

  def printable?
    # valid?(:printable) || puts(errors.full_messages)
    # user.printable? || puts(errors.full_messages)
    cf0925_printable = valid?(:printable)
    user_printable = user.printable?
    # puts "user validation: #{user_printable}. CF0925 validate: #{cf0925_printable}"
    # puts "Both: #{cf0925_printable && user_printable}"
    cf0925_printable && user_printable
  end

  ##
  # Save the RTP and the user that owns the RTP.
  def save_with_user
    ActiveRecord::Base.transaction do
      save!
      user.save!
    end
  rescue => e
    logger.warn "Failed to save #{inspect} #{e}"
    # FIXME: Re-raise here rather than return, methinks.
    return false
  end

  ##
  # Return the range from start date to end date, or fiscal year of part B.
  def service_period(start = service_provider_service_start,
    finish = service_provider_service_end)
    if start && finish
      start..finish
    else
      # fy = funded_person.fiscal_year(created_at)
      fy = FiscalYear.new(part_b_fiscal_year)
      service_period(fy.begin, fy.end)
    end
  end

  ##
  # Return a human-digestable string for the service period.
  def service_period_string
    [service_period.begin.to_s, service_period.end.to_s].join(" to ")
  end

  def service_provider_service_amount=(value)
    super number_clean(value)
  end

  def service_provider_service_fee=(value)
    super number_clean(value)
  end

  def set_form
    form || self.form = Form.find_by!(class_name: "Cf0925")
  end

  def start_date
    service_provider_service_start
  end

  def start_date_before_end_date
    return if service_provider_service_start.blank? || service_provider_service_end.blank?

    errors.add(:service_provider_service_end, "must be after start date") if
      service_provider_service_end < service_provider_service_start
  end

  def start_and_end_dates_in_same_fiscal_year
    return if service_provider_service_start.blank? || service_provider_service_end.blank?
    if funded_person.fiscal_year(service_provider_service_start) !=
       funded_person.fiscal_year(service_provider_service_end)
      errors.add(:service_provider_service_end,
        "service end date must be in the same fiscal year " \
        "as service start date")
    end
  end

  def status
    return "Ready to Print" if printable?
    "Not Complete"
  end

  ##
  # A human-usable way to identify an RTP.
  # Useful for drop-downs, etc.
  def to_s
    [
      (service_provider_name || agency_name || supplier_name),
      service_period_string
    ].join(" ")
  end

  ##
  # Total amount requested on this CF0925
  def total_amount
    # puts "amount: #{service_provider_service_amount} item_total: #{item_total}"
    # puts 'Item total is false' unless item_total
    (service_provider_service_amount || 0) + (item_total || 0)
  end

  def translate_care_of_ministry_to_pdf_field
    child_in_care_of_ministry ? "Choice1" : "Choice2"
  end

  def translate_payment_to_pdf_field
    payment == "provider" ? "Choice1" : "Choice2"
  end

  def user
    funded_person && funded_person.user
  end

  private

  def adjust_invoice_allocations(type)
    invoice_allocations
      .select { |ia| ia.cf0925_type == type }
      .sort { |a, b| compare_invoice_allocations(a, b) }
      .reverse_each do |ia|
      # puts "ia.inspect: #{ia.inspect} " \
      #   "ia.invoice_invoice_amount: #{ia.invoice_invoice_amount}"
      # TODO: This implementation, with that of
      # InvoiceAllocation#amount_available, is not the most performant
      if ia.amount_available < 0
        # puts "ia.amount_available #{ia.amount_available}"
        ia.amount -= [ia.amount, -ia.amount_available].min
      end
    end
  end

  def compare_invoice_allocations(a, b)
    result = a.invoice_invoice_date <=> b.invoice_invoice_date if
              a.invoice_invoice_date && b.invoice_invoice_date
    result = a.invoice_service_end <=> b.invoice_service_end if
              result == 0 && a.invoice_service_end && b.invoice_service_end
    result = a.invoice_service_start <=> b.invoice_service_start if
              result == 0 && a.invoice_service_start && b.invoice_service_start
    result
  end

  def formatted_area_code(match)
    match[:area_code] if match
  end

  def formatted_currency(amount)
    number_to_currency(amount, unit: "")
  end

  def formatted_phone_number(match)
    number_to_phone(match[:exchange] + match[:number],
      extension: match[:ext]) if match
  end

  def number_clean(value)
    return value unless value.is_a? String
    value.gsub(/[^\d#{I18n.default_separator}]+/, "")
  end
end
