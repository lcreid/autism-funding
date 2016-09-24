class Cf0925 < ApplicationRecord
  include Helpers::FiscalYear

  belongs_to :form
  belongs_to :funded_person, inverse_of: :cf0925s
  has_many :invoices
  # accepts_nested_attributes_for :funded_person

  validates :service_provider_service_start,
            :service_provider_service_end,
            presence: true,
            on: :printable
  validate :start_date_before_end_date, on: :printable
  validates :payment,
            presence: {
              message: 'please choose either service provider or agency'
            },
            on: :printable

  before_validation :set_form

  # We don't want to validate on these because the user should be able to
  # enter and save partial records.
  # validates :child_dob,
  #           :child_first_name,
  #           :child_last_name,
  #           :child_middle_name,
  #           :child_in_care_of_ministry,
  #           :home_phone,
  #           :parent_address,
  #           :parent_city,
  #           :parent_first_name,
  #           :parent_last_name,
  #           :parent_middle_name,
  #           :parent_postal_code,
  #           :work_phone,
  #           presence: true
  # It should be a validation that the start and end dates are in the same
  # fiscal year.

  def client_pdf_file_name
    child_last_name + '-' +
      child_first_name + '-' +
      id.to_s +
      '.pdf'
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

  def item_total
    return '' unless item_cost_1 && item_cost_2 && item_cost_3
    item_cost_1 +
      item_cost_2 +
      item_cost_3
  end

  def pdf_output_file
    "/tmp/cf0925_#{id}.pdf"
  end

  def printable?
    valid?(:printable) &&
      !child_dob.blank? &&
      !child_first_name.blank? &&
      !child_last_name.blank? &&
      (!home_phone.blank? || !work_phone.blank?) &&
      !parent_address.blank? &&
      !parent_city.blank? &&
      !parent_first_name.blank? &&
      !parent_last_name.blank? &&
      !parent_postal_code.blank? &&
      !service_provider_postal_code.blank? &&
      !service_provider_address.blank? &&
      !service_provider_city.blank? &&
      !service_provider_phone.blank? &&
      !service_provider_name.blank? &&
      !service_provider_service_1.blank? &&
      !service_provider_service_amount.blank? &&
      !service_provider_service_end.blank? &&
      !service_provider_service_fee.blank? &&
      !service_provider_service_hour.blank? &&
      !service_provider_service_start.blank?
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

  def status
    return 'Ready to Print' if printable?
    'Not Complete'
  end

  def user
    funded_person.user
  end

  def translate_payment_to_pdf_field
    payment == 'provider' ? 'Choice2' : 'Choice1'
  end

  def translate_care_of_ministry_to_pdf_field
    child_in_care_of_ministry ? 'Choice1' : 'Choice2'
  end

  private
end
