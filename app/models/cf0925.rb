##
# Request to pay form for BC
class Cf0925 < ApplicationRecord
  include Helpers::FiscalYear
  include Formatters
  include ActionView::Helpers::NumberHelper

  belongs_to :form
  belongs_to :funded_person, inverse_of: :cf0925s
  has_many :invoices
  # accepts_nested_attributes_for :funded_person

  validates :service_provider_service_start,
            :service_provider_service_end,
            :child_dob,
            :child_first_name,
            :child_last_name,
            # :child_in_care_of_ministry, TODO: validate this.
            presence: true,
            on: :printable
  validates :work_phone,
            presence: true,
            on: :printable,
            unless: ->(x) { x.home_phone.present? }
  validates :home_phone,
            presence: true,
            on: :printable,
            unless: ->(x) { x.work_phone.present? }

  # It should be a validation that the start and end dates are in the same
  # fiscal year.
  validate :start_date_before_end_date, on: :printable
  validate :start_and_end_dates_in_same_fiscal_year, on: :printable
  validates :payment,
            presence: {
              message: 'please choose either service provider or agency'
            },
            on: :printable

  before_validation :set_form

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

  def item_total
    return nil unless item_cost_1 || item_cost_2 || item_cost_3
    (item_cost_1 || 0) +
      (item_cost_2 || 0) +
      (item_cost_3 || 0)
  end

  def pdf_output_file
    "/tmp/cf0925_#{id}.pdf"
  end

  def printable?
    # valid?(:printable) || puts(errors.full_messages)
    cf0925_printable = valid?(:printable)
    user_printable = user.printable?
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
  # Total amount requested on this CF0925
  def total_amount
    # puts "amount: #{service_provider_service_amount} item_total: #{item_total}"
    # puts 'Item total is false' unless item_total
    (service_provider_service_amount || 0) + (item_total || 0)
  end

  def user
    funded_person.user
  end

  def translate_payment_to_pdf_field
    payment == 'provider' ? 'Choice1' : 'Choice2'
  end

  def translate_care_of_ministry_to_pdf_field
    child_in_care_of_ministry ? 'Choice1' : 'Choice2'
  end

  private

  def formatted_area_code(match)
    match[:area_code] if match
  end

  def formatted_currency(amount)
    puts "formatted_currency(#{amount}) #{number_to_currency(amount, unit: '')}"
    number_to_currency(amount, unit: '')
  end

  def formatted_phone_number(match)
    number_to_phone(match[:exchange] + match[:number],
                    extension: match[:ext]) if match
  end
end
