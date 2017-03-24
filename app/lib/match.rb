class Match
  def initialize(cf0925_type, cf0925 = nil)
    case cf0925_type
    when String
      raise unless cf0925
      @cf0925 = cf0925
      @cf0925_type = cf0925_type
    when InvoiceAllocation
      @cf0925 = cf0925_type.cf0925
      @cf0925_type = cf0925_type.cf0925_type
    else
      raise
    end
  end

  def <=>(other)
    cf0925 <=> other.cf0925 || cf0925_type <=> other.cf0925_type
  end

  def ==(other)
    case other
    when InvoiceAllocation, Match
      cf0925 == other.cf0925 && cf0925_type == other.cf0925_type
    else
      super
    end
  end

  alias eql? ==

  attr_reader :cf0925, :cf0925_type

  delegate :service_period_string, to: :cf0925
end
