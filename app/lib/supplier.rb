##
# InvoiceAllocation when being used to pay for a supplier invoice
module Supplier
  def display_start_date
    cf0925.funded_person.fiscal_year(cf0925.created_at).begin
  end

  def display_end_date
    cf0925.funded_person.fiscal_year(cf0925.created_at).end
  end

  def payee
    cf0925.supplier_name
  end

  def requested_amount
    cf0925.item_total
  end
end
