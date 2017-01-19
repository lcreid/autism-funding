##
# Join model for RTP and invoice
class InvoiceAllocation < ApplicationRecord
  belongs_to :cf0925, autosave: true
  belongs_to :invoice, autosave: true
end
