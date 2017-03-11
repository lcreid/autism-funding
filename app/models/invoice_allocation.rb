##
# Join model for RTP and invoice.
# Instnaces of this model are generated by `Invoice#allocate`.
# In normal operation, `Invoice#allocate` is called when the user is entering
# or updating an `Invoice`, and *after* a user changes a `Cf0925`.
#
# If you have to manually delete an `InvoiceAllocation` for some reason, you
# also have to manually regenerate `InvoiceAllocation`s or the
# `InvoicesController#edit` action won't show the user that there are
# matching `Cf0925`s for the invoice.
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
    # puts "------------ A boo at InvoiceAllocations -------------------------"
    # InvoiceAllocation.all.each { |ia|
    #   puts "id: #{ia.id}  cf0925_id: #{ia.cf0925_id}  invoice_id: #{ia.invoice_id} cf0925_type: #{ia.cf0925_type} amount: #{ia.amount}"
    #
    # }
    # puts "-------------------------------------------------------------------"
    res = requested_amount - cf0925
                       .invoice_allocations
                       .select { |ia| ia.cf0925_type == cf0925_type && ia.amount }
                       .sum(&:amount)
    # puts "!!!!!invoice_allocation.rb:#{__LINE__} - amount_available: #{res} cf0925.id #{cf0925.id} amount: #{amount}"
    # puts "invoice_allocation.id: #{id}"
    # puts "-------------------------------------------------------------------"
    # puts "This: id: #{id}  cf0925_id: #{cf0925_id}  invoice_id: #{invoice_id} cf0925_type: #{cf0925_type} amount: #{amount}"
    # puts "-------------------------------------------------------------------"
    # puts cf0925.invoice_allocations.inspect
    # puts "-------------------------------------------------------------------"
    # partb = cf0925
    #           .invoice_allocations
    #           .select { |ia| ia.cf0925_type == cf0925_type && ia.amount }
    #           .sum(&:amount)
    #
    # puts "requested_amount: #{requested_amount} partb: #{partb}"
    # puts "-------------------------------------------------------------------"
    # cf0925.invoice_allocations.each { |ia|
    #   yeah = false
    #   if (ia.cf0925_type == cf0925_type && amount)
    #       yeah = true
    #   end
    #   yeah1 = false
    #   if (ia.cf0925_type == cf0925_type)
    #       yeah1 = true
    #   end
    #   yeah2 = false
    #   if (amount)
    #       yeah2 = true
    #   end
    #   puts "Line #{__LINE__}: amount: #{ia.amount}  cf0925_type #{cf0925_type} true?: #{yeah} part1?: #{yeah1}  part2?: #{yeah2} class: #{amount.class}"
    #
    # }
    # puts "-------------------------------------------------------------------"
    res
  end

  def cf0925_type=(other)
    super
    extend_by_type
  end

  def requested_minus_other_invoices
    amount_available + (amount || 0)
  end

  private

  def extend_by_type
    mod = Module.const_get(cf0925_type)
    extend(mod)
    cf0925_type
  end
end
