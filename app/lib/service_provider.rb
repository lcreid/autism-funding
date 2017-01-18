##
# RTP when being used to pay for an agency or service provider invoice
module ServiceProvider
  def start_date
    service_provider_service_start
  end

  def end_date
    service_provider_service_end
  end

  def payee
    service_provider_name || agency_name
  end

  def requested_amount
    service_provider_service_amount
  end
end
