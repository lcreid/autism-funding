##
# RTP when being used to pay for a supplier invoice
module Supplier
  def display_start_date
    fiscal_year.begin
  end

  def display_end_date
    fiscal_year.end
  end

  def payee
    supplier_name
  end

  def requested_amount
    item_total
  end
end
