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

  def +(other)
    (first + other.years)..(last + other.years)
  end

  ##
  # Sort on start date of fiscal year.
  def <=>(other)
    first <=> other.first
  end

  ##
  # Creates a Range of Dates, with some additional functionality.
  # If param is a Date, the fiscal year starts on the date and ends the day
  # before next year, including the end point, e.g. 2015-03-01 to
  # 2016-02-29.
  # If param is a Range, the fiscal year is simply the range.
  # No check is made that the range is actually a year long.
  def initialize(param)
    case param
    when Range
      super(param.begin, param.end, param.exclude_end?)
    when Date
      super(param, param.next_year - 1.day)
    else
      super
    end
  end

  ##
  # Get the fiscal year following this fiscal year
  # This is needed for the each in upto.
  def succ
    FiscalYear.new(self + 1)
  end

  ##
  # Show the fiscal year as 'YYYY-YYYY', or just 'YYYY' if the fiscal year
  # is the calendar year.
  def to_s
    fy = first.year.to_s
    end_year = last.year
    fy += '-' + end_year.to_s unless first.year == end_year
    fy
  end

  ##
  # I guess I have to do my own implementation of upto.
  def upto(limit)
    return enum_for(:upto, limit) unless block_given?

    (self..limit).each { |fy| yield fy }
  end
end
