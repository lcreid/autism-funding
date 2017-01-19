##
# RTP when being used to pay for a supplier invoice
module Supplier
  def display_start_date
    funded_person.fiscal_year(created_at).begin
  end

  def display_end_date
    funded_person.fiscal_year(created_at).end
  end

  def payee
    supplier_name
  end

  def requested_amount
    item_total
  end
end
