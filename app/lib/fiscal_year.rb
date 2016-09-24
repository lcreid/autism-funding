##
# Fiscal year for a child.
class FiscalYear < Range
  ##
  # Convenience to be able to initialize from a Range.
  def initialize(range)
    super(range.begin, range.end, range.exclude_end?)
    # @range = range
  end

  ##
  # Sort on start date of fiscal year.
  def <=>(other)
    first <=> other.first
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
