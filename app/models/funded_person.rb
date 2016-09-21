class FundedPerson < ApplicationRecord
  # One record for each funded person
  # ----- Associations ---------------------------------------------------------
  belongs_to :user, inverse_of: :funded_people
  accepts_nested_attributes_for :user

  has_many :cf0925s, inverse_of: :funded_person
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  validates :birthdate, presence: true
  validate :birthdate_cannot_be_in_the_future
  validate :must_define_at_least_one_name

  # ----- Public Methods -------------------------------------------------------
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
    date = date.to_date unless date.is_a?(Date)
    start_of_first_fiscal_year = birthdate.next_month.beginning_of_month
    start_of_fiscal_year = start_of_first_fiscal_year.change(year: date.year)
    start_of_fiscal_year -= 1.year if date < start_of_fiscal_year
    start_of_fiscal_year...start_of_fiscal_year.next_year
  end

  def must_define_at_least_one_name
    if my_name == 'no name defined'
      errors.add(:name, ' - must define at least one name')
    end
  end
  #-----------------------------------------------------------------------------

  # ----- Private Methods -------------------------------------------------------
  #-----------------------------------------------------------------------------
end
