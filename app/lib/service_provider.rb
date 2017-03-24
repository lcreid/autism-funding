##
# RTP when being used to pay for an agency or service provider invoice
module ServiceProvider
  def display_start_date
    cf0925.service_provider_service_start
  end

  def display_end_date
    cf0925.service_provider_service_end
  end

  def payee
    cf0925.service_provider_name || cf0925.agency_name
  end

  def requested_amount
    cf0925.service_provider_service_amount
  end
end
