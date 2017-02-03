##
# Fiscal year for a child.
class FiscalYear < Range
  def <(other)
    last < other.first
  end

  def <=(other)
    last < other.first || self == other
  end

  def >(other)
    first > other.last
  end

  def >=(other)
    first > other.last || self == other
  end

  ##
  # Sort on start date of fiscal year.
  def <=>(other)
    first <=> other.first
  end

  ##
  # Convenience to be able to initialize from a Range.
  def initialize(param)
    case param
    when Range
      super(param.begin, param.end, param.exclude_end?)
    when Date
      super(param, param.next_year - 1.day)
    end
  end

  ##
  # Show the fiscal year as 'YYYY-YYYY', or just 'YYYY' if the fiscal year
  # is the calendar year.
  def to_s
    fy = first.year.to_s
    end_year = (last - 1.second).year
    fy += '-' + last.year.to_s unless first.year == end_year
    fy
  end
end
