##
# Join model for RTP and invoice
class InvoiceAllocation < ApplicationRecord
  belongs_to :cf0925, autosave: true, inverse_of: :invoice_allocations
  belongs_to :invoice, autosave: true, inverse_of: :invoice_allocations
end
