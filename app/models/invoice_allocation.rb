##
# Join model for RTP and invoice
class InvoiceAllocation < ApplicationRecord
  belongs_to :cf0925, autosave: true, inverse_of: :invoice_allocations
  # delegate *Cf0925.column_names, to: :cf0925, prefix: true
  belongs_to :invoice, autosave: true, inverse_of: :invoice_allocations

  validates :cf0925_type,
            presence: true,
            inclusion: { in: %w(ServiceProvider Supplier) }

  def cf0925(force_reload = false)
    obj = super
    mod = Module.const_get(cf0925_type)
    obj.singleton_class.include?(mod) || obj.extend(mod)
    obj
  end
end
