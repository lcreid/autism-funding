class Invoice < ApplicationRecord
  include Helpers::FiscalYear

  # One record for each address
  # ----- Associations ---------------------------------------------------------
  belongs_to :funded_person
  belongs_to :cf0925, optional: true
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  #-----------------------------------------------------------------------------
  # ----- Callbacks ------------------------------------------------------------
  #-----------------------------------------------------------------------------

  # ----- Public Methods -------------------------------------------------------
  def invoice_from
    invoice_from = ''
    del = ''
    unless service_provider_name.blank?
      invoice_from = "#{invoice_from}#{del}#{service_provider_name}"
      del = ' / '
    end
    unless supplier_name.blank?
      invoice_from = "#{invoice_from}#{del}#{supplier_name}"
      del = ' / '
    end
    unless agency_name.blank?
      invoice_from = "#{invoice_from}#{del}#{agency_name}"
      del = ' / '
    end

    invoice_from = 'No invoicee defined' if invoice_from == ''
    invoice_from
  end

  def start_date
    service_start
  end

  #-----------------------------------------------------------------------------
  # ----- Protected Methods ----------------------------------------------------

  #  protected

  #-----------------------------------------------------------------------------

  # ----- Private Methods -------------------------------------------------------
  #-----------------------------------------------------------------------------
end
