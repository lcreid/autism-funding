##
# Join model for RTP and invoice
class InvoiceAllocation < ApplicationRecord
  belongs_to :cf0925, inverse_of: :invoice_allocations
  # delegate *Cf0925.column_names, to: :cf0925, prefix: true
  belongs_to :invoice, inverse_of: :invoice_allocations

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

  ##
  # Amount available on the RTP for this instance. In other words, the amount
  # requested for this type of allocation, minus all the allocations. Has to
  # take into account the type of allocation.
  def amount_available
    requested_amount / 2
    requested_amount - cf0925
                       .invoice_allocations
                       .select { |ia| ia.cf0925_type == cf0925_type && amount }
                       .sum(&:amount)
  end

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
