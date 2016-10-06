class FundedPerson < ApplicationRecord
  # One record for each funded person
  # ----- Associations ---------------------------------------------------------
  belongs_to :user, inverse_of: :funded_people
  accepts_nested_attributes_for :user

  has_many :cf0925s, inverse_of: :funded_person
  has_many :invoices
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  validates :birthdate, presence: true
  validate :birthdate_cannot_be_in_the_future
  validate :must_define_at_least_one_name

  # ----- Public Methods -------------------------------------------------------
  def cf0925s_in_fiscal_year(fy)
    # pp cf0925s.select { |x| fy.include?(x.fiscal_year) }.map(&:inspect)
    cf0925s.select { |x| fy.include?(x.fiscal_year) }
  end

  def invoices_in_fiscal_year(fy)
    # pp invoices.select { |x| fy.include?(x.fiscal_year) }.map(&:inspect)
    invoices.select { |x| fy.include?(x.fiscal_year) }
  end

  def my_name
    my_name = "#{name_first} #{name_middle}".strip
    my_name = "#{my_name} #{name_last}".strip
    my_name = 'no name defined' if my_name == ''
    my_name
  end

  #-----------------------------------------------------------------------------
  def my_dob(frm_str = '%Y-%m-%d')
    my_dob = if birthdate.nil?
               'undefined'
             else
               birthdate.strftime(frm_str)
             end
    my_dob
  end

  # ----- Validation Methods ---------------------------------------------------
  def birthdate_cannot_be_in_the_future
    if birthdate.present? && birthdate > Date.today
      errors.add(:birthdate, " - can't be in the future")
    end
  end

  def fiscal_year(date)
    case date
    when FiscalYear
      date
    when String
      fy_parts = /(\d+{4,})(-(\d+{4,}))?/.match(date)
      # puts "First year: #{fy_parts[1]} Second year: #{fy_parts[3]}"
      start_of_fiscal_year = start_of_first_fiscal_year.change(year: fy_parts[1].to_i)
      FiscalYear.new(start_of_fiscal_year...start_of_fiscal_year.next_year)
    else
      date = date.to_date unless date.is_a?(Date)
      start_of_fiscal_year = start_of_first_fiscal_year.change(year: date.year)
      start_of_fiscal_year -= 1.year if date < start_of_fiscal_year
      FiscalYear.new(start_of_fiscal_year...start_of_fiscal_year.next_year)
    end
  end

  ##
  # Return a list of fiscal years for which there is some sort of activity
  # for the FundedPerson. The list is sorted in descending order from the
  # most recent fiscal year.
  # TODO: Add other sources of paperwork as they become available (Invoice).
  def fiscal_years
    (cf0925s.map(&:fiscal_year) | invoices.map(&:fiscal_year))
      .sort { |x, y| y <=> x }
  end

  def must_define_at_least_one_name
    if my_name == 'no name defined'
      errors.add(:name, ' - must define at least one name')
    end
  end

  def selected_fiscal_year
    @selected_fiscal_year ||= fiscal_years.first
  end

  def selected_fiscal_year=(fy)
    case fy
    when FiscalYear
      @selected_fiscal_year = fy
    when Range
      @selected_fiscal_year = FiscalYear.new(fy)
    when String
      # FIXME: put String in the FY initializer. Not as simple as that.
      # The FiscalYear class doesn't have the child's DOB, probably
      # rightly so.
      @selected_fiscal_year = fiscal_years.find { |i| fy == i.to_s }
    end
  end

  def start_of_first_fiscal_year
    birthdate.next_month.beginning_of_month
  end

  def status(fy)
    Status.new(self, fiscal_year(fy))
  end

  #-----------------------------------------------------------------------------

  # ----- Private Methods -------------------------------------------------------
  #-----------------------------------------------------------------------------
  def fiscal_year_from_year(year)
    start_of_fiscal_year = start_of_first_fiscal_year.change(year: year)
    start_of_fiscal_year -= 1.year if date < start_of_fiscal_year
    FiscalYear.new(start_of_fiscal_year...start_of_fiscal_year.next_year)
  end
end
