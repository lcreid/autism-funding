##
# Join model for RTP and invoice
class InvoiceAllocation < ApplicationRecord
  belongs_to :cf0925, autosave: true, inverse_of: :invoice_allocations
  # delegate *Cf0925.column_names, to: :cf0925, prefix: true
  belongs_to :invoice, autosave: true, inverse_of: :invoice_allocations

  validates :cf0925_type,
            presence: true,
            inclusion: { in: %w(ServiceProvider Supplier) }

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

  # TODO: This should no longer be needed. Take it out and make sure
  # everything still works.
  # Probably not that simple, as we still need the behaviour that changes
  # depending on the Match/InvoiceAllocation
  def cf0925(force_reload = false)
    obj = super
    mod = Module.const_get(cf0925_type)
    obj.singleton_class.include?(mod) || obj.extend(mod)
    obj
  end

  # TODO: Remove this. It was for another approach that didn't work.
  # def self.allocate(cf0925_type, invoice = nil, rtp = nil)
  #   ia = InvoiceAllocation.new
  #   ia.invoice = invoice
  #   invoice.invoice_allocations << ia if invoice
  #   ia.cf0925 = rtp
  #   rtp.invoice_allocations << ia if rtp
  #   ia.cf0925_type = cf0925_type
  #   ia
  # end
end
