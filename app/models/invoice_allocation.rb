##
# Join model for RTP and invoice
class InvoiceAllocation < ApplicationRecord
  belongs_to :cf0925, autosave: true, inverse_of: :invoice_allocations
  # delegate *Cf0925.column_names, to: :cf0925, prefix: true
  belongs_to :invoice, autosave: true, inverse_of: :invoice_allocations

  validates :cf0925_type,
            presence: true,
            inclusion: { in: %w(ServiceProvider Supplier) }

  after_initialize :extend_by_type

  ##
  # Supports testing if not other things
  def <=>(other)
    cf0925 <=> other.cf0925 || cf0925_type <=> other.cf0925_type
  end

  ##
  # Supports testing if not other things.
  def ==(other)
    case other
    when Match
      cf0925 == other.cf0925 && cf0925_type == other.cf0925_type
    else
      super
    end
  end

  alias eql? ==

  def cf0925_type=(other)
    super
    extend_by_type
  end

  private

  def extend_by_type
    mod = Module.const_get(cf0925_type)
    extend(mod)
    cf0925_type
  end
end
