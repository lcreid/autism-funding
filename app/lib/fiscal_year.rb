class FiscalYear
  attr_reader :range

  def initialize(range)
    @range = range
  end

  def <=>(other)
    return @range.first <=> other if other.is_a? Range
    return @range.first <=> other.range.first if other.is_a? FiscalYear
    nil
  end

  def ==(other)
    return @range == other if other.is_a? Range
    return @range == other.range if other.is_a? FiscalYear
    false
  end

  def eql?(other)
    self == other
  end

  def hash
    @range.hash
  end

  ##
  # Show the fiscal year as 'YYYY-YYYY', or just 'YYYY' if the fiscal year
  # is the calendar year.
  def to_s
    fy = @range.first.year.to_s
    end_year = (@range.last - 1.second).year
    fy += '-' + @range.last.year.to_s unless @range.first.year == end_year
    fy
  end
end
