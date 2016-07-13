class Cf0925 < ApplicationRecord
  # validates :service_provider_service_start,
  #           :service_provider_service_end,
  #           presence: true
  validate :start_date_before_end_date
  validates :payment,
            presence: {
              message: 'please choose either service provider or agency'
            }

  def generate_pdf
    # begin
    pdftk = PdfForms.new('/usr/bin/pdftk')
    pdftk.fill_form(File.join(Rails.root, 'app/assets/pdf_forms/cf_0925.pdf'),
                    pdf_file,
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
                      phn_SP: service_provider_phone[3..-1],
                      sup_ph: supplier_phone[3..-1],
                      parent_city: parent_city,
                      parent_PC: parent_postal_code,
                      parent_fst_name: parent_first_name,
                      chld_fst_name: child_first_name,
                      parent_mid_name: parent_middle_name,
                      chld_mid_name: child_middle_name,
                      hm_phn_area: home_phone[0..2],
                      hm_phn: home_phone[3..-1],
                      chld_DOB: format_date(child_dob),
                      chld_yn: 'Choice1', # This comes from radio buttons
                      Payment: 'Choice2', # This comes from radio buttons
                      wrk_phn_area: work_phone[0..2],
                      wrk_phn: work_phone[3..-1]
                    },
                    flatten: true)
    # rescue PdfForms::PdftkError => e
    # puts e.to_s
    # return false
    # end
    true
  end

  def format_date(date)
    date
  end

  def item_total
    return '' unless item_cost_1 && item_cost_2 && item_cost_3
    item_cost_1 +
      item_cost_2 +
      item_cost_3
  end

  def pdf_file
    "/tmp/cf0925_#{id}.pdf"
  end

  def start_date_before_end_date
    # return if start_date.blank? || end_date.blank?

    errors.add(:service_provider_service_end, 'must be after start date') if
      service_provider_service_end < service_provider_service_start
  end
end
