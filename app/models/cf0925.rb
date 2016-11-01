##
# Request to pay form for BC
# TODO: The second page (instructions) for the CF_0925 says to put the date
# of training or travel on the details lines. Doesn't say how to give date
# for a purchase.
class Cf0925 < ApplicationRecord
  include Helpers::FiscalYear

  belongs_to :form
  belongs_to :funded_person, inverse_of: :cf0925s
  has_many :invoices
  # accepts_nested_attributes_for :funded_person

  validates :service_provider_service_start,
            :service_provider_service_end,
            presence: true,
            on: :printable,
            unless: :supplier_only_rtp?
  validates :child_dob,
            :child_first_name,
            :child_last_name,
            presence: true,
            on: :printable
  validates_inclusion_of :child_in_care_of_ministry,
                         in: [true, false],
                         on: :printable
  validates :work_phone,
            presence: true,
            on: :printable,
            unless: ->(x) { x.home_phone.present? }
  validates :home_phone,
            presence: true,
            on: :printable,
            unless: ->(x) { x.work_phone.present? }

  # FIXME: There should be a validation that the start and end dates are in
  # the same fiscal year.
  validate :start_date_before_end_date,
           on: :printable,
           unless: :supplier_only_rtp?
  validate :start_and_end_dates_in_same_fiscal_year,
           on: :printable,
           unless: :supplier_only_rtp?
  validates :payment,
            presence: {
              message: 'please choose either service provider or agency'
            },
            on: :printable,
            unless: :supplier_only_rtp?

  # TODO: Validate that request is less than maximum.
  # TODO: Validate that request is less than remaining amount.
  # TODO: (optional) Validate that request is this year or next year (warning?)
  # TODO: Validate that Part B funding is no more than 20% of available funding.
  before_validation :set_form

  # It should be a validation that the start and end dates are in the same
  # fiscal year.

  def client_pdf_file_name
    child_last_name + '-' +
      child_first_name + '-' +
      id.to_s +
      '.pdf'
  end

  def copy_parent_to_form
    self.parent_last_name = user.name_last
    self.parent_first_name = user.name_first
    self.parent_middle_name = user.name_middle
    # puts "In copy_parent_to_form home phone: #{user.home_phone.full_number}"
    self.home_phone = user.home_phone.full_number if user.home_phone
    self.work_phone = user.work_phone.full_number if user.work_phone
    self.parent_address = user.address.address_line_1 if user.address
    self.parent_city = user.address.city if user.address
    self.parent_postal_code = user.address.postal_code if user.address
  end

  def copy_child_to_form
    # puts "Before: #{child_dob}"
    self.child_last_name = funded_person.name_last
    self.child_first_name = funded_person.name_first
    self.child_middle_name = funded_person.name_middle
    self.child_dob = funded_person.my_dob
    self.child_in_care_of_ministry = funded_person.child_in_care_of_ministry
    # puts "After: #{child_dob}"
  end

  def include?(range)
    Range.new(service_provider_service_start, service_provider_service_end)
         .include?(range)
  end

  def format_date(date)
    date
  end

  def generate_pdf
    # begin
    pdftk = PdfForms.new('/usr/bin/pdftk')
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
                      item_cost_1: item_cost_1,
                      item_cost_2: item_cost_2,
                      item_total: item_total,
                      item_cost_3: item_cost_3,
                      item_desp_2: item_desp_2,
                      item_desp_3: item_desp_3,
                      cnt_person: supplier_contact_person,
                      city_sup: supplier_city,
                      PC_sup: supplier_postal_code,
                      city_SP: service_provider_city,
                      PC_SP: service_provider_postal_code,
                      SP_serv_start: format_date(service_provider_service_start),
                      SP_serv_fee: service_provider_service_fee,
                      SP_serv_hr: service_provider_service_hour,
                      SP_serv_amt: service_provider_service_amount,
                      SP_serv_end: format_date(service_provider_service_end),
                      ph_area_SP: service_provider_phone[0..2],
                      sup_area_ph: supplier_phone[0..2],
                      phn_SP: service_provider_phone[4..-1],
                      sup_ph: supplier_phone[4..-1],
                      parent_city: parent_city,
                      parent_PC: parent_postal_code,
                      parent_fst_name: parent_first_name,
                      chld_fst_name: child_first_name,
                      parent_mid_name: parent_middle_name,
                      chld_mid_name: child_middle_name,
                      hm_phn_area: home_phone[1..3],
                      hm_phn: home_phone[5..-1],
                      chld_DOB: format_date(child_dob),
                      chld_yn: translate_care_of_ministry_to_pdf_field, # This comes from radio buttons
                      Payment: translate_payment_to_pdf_field, # This comes from radio buttons
                      wrk_phn_area: work_phone[1..3],
                      wrk_phn: work_phone[5..-1]
                    },
                    flatten: true)
    # rescue PdfForms::PdftkError => e
    # puts e.to_s
    # return false
    # end
    true
  end

  def in_fiscal_year(fy)
    fy.includes?(fiscal_year)
  end

  def item_total
    return nil unless item_cost_1 || item_cost_2 || item_cost_3
    (item_cost_1 || 0) +
      (item_cost_2 || 0) +
      (item_cost_3 || 0)
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

  def set_form
    form || self.form = Form.find_by!(class_name: 'Cf0925')
  end

  def start_date
    service_provider_service_start
  end

  def start_date_before_end_date
    return if service_provider_service_start.blank? || service_provider_service_end.blank?

    errors.add(:service_provider_service_end, 'must be after start date') if
      service_provider_service_end < service_provider_service_start
  end

  def start_and_end_dates_in_same_fiscal_year
    return if service_provider_service_start.blank? || service_provider_service_end.blank?
    if funded_person.fiscal_year(service_provider_service_start) !=
       funded_person.fiscal_year(service_provider_service_end)
      errors.add(:service_provider_service_end,
                 'service end date must be in the same fiscal year ' \
                 'as service start date')
    end
  end

  def status
    return 'Ready to Print' if printable?
    'Not Complete'
  end

  ##
  # Some validations aren't needed if this is a supplier-only RTP
  def supplier_only_rtp?
    service_provider_name.blank? &&
      agency_name.blank? &&
      service_provider_service_start.blank? &&
      service_provider_service_end.blank? &&
      payment.blank? &&
      supplier_name.present?
  end

  ##
  # Total amount requested on this CF0925
  def total_amount
    # puts "amount: #{service_provider_service_amount} item_total: #{item_total}"
    # puts 'Item total is false' unless item_total
    (service_provider_service_amount || 0) + (item_total || 0)
  end

  def translate_care_of_ministry_to_pdf_field
    child_in_care_of_ministry ? 'Choice1' : 'Choice2'
  end

  def translate_payment_to_pdf_field
    payment == 'provider' ? 'Choice2' : 'Choice1'
  end

  def user
    funded_person.user
  end

  private
end
