class FundedPerson < ApplicationRecord
  include Preferences

  # One record for each funded person
  # ----- Associations ---------------------------------------------------------
  belongs_to :user, inverse_of: :funded_people #, autosave: true
  #  accepts_nested_attributes_for :user

  default_scope { order(:name_first) }

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
    association_in_fiscal_year(cf0925s, fy)
  end

  def cf0925s_in_selected_fiscal_year
    cf0925s_in_fiscal_year(selected_fiscal_year)
  end

  def childs_panel_state
    # child_preference(:panel_state, :closed).to_sym
    logger.debug("Child #{id}: #{id == user.open_panel ? :open : :closed}")
    id == user.open_panel ? :open : :closed
  end

  def childs_selected_fiscal_year
    fiscal_year(child_preference(:selected_fiscal_year, fiscal_years.first))
  end

  def invoices_in_fiscal_year(fy)
    # pp invoices.select { |x| fy.include?(x.fiscal_year) }.map(&:inspect)
    association_in_fiscal_year(invoices, fy)
  end

  def invoices_in_selected_fiscal_year
    invoices_in_fiscal_year(selected_fiscal_year)
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
      FiscalYear.new(start_of_fiscal_year)
    when nil
      nil
    else
      date = date.to_date unless date.is_a?(Date)
      start_of_fiscal_year = start_of_first_fiscal_year.change(year: date.year)
      start_of_fiscal_year -= 1.year if date < start_of_fiscal_year
      FiscalYear.new(start_of_fiscal_year)
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

  # Return true if name, birthdate and in care of ministry fields are all blank
  def is_blank?
    child_in_care_of_ministry.nil? && my_dob == 'undefined' && my_name == 'no name defined'
  end

  def must_define_at_least_one_name
    if my_name == 'no name defined'
      errors.add(:name_last, ' - must define at least one name')
      errors.add(:name_first, ' - must define at least one name')
    end
  end

  def selected_fiscal_year
    childs_selected_fiscal_year
  end

  def selected_fiscal_year=(fy)
    set_childs_selected_fiscal_year(case fy
                                    when FiscalYear
                                      fy
                                    when Range
                                      FiscalYear.new(fy)
                                    when String
                                      # The FiscalYear class doesn't have the child's DOB, probably
                                      # TODO: put String in the FY initializer. Not as simple as that.
                                      # rightly so.
                                      fiscal_years.find { |i| fy == i.to_s }
                                    end)
    logger.debug { "Set selected fiscal year for #{my_name} to #{selected_fiscal_year}" }
    selected_fiscal_year
  end

  def set_childs_panel_state(state)
    # set_child_preference(:panel_state, state).to_sym
    # puts("Setting panel to #{state} for #{id}")
    logger.debug("Setting panel to #{state} for #{id}")
    # puts 'Set a panel to open' if state.to_sym == :open
    user.set_open_panel(id) if state.to_sym == :open
    state
  end

  def set_childs_selected_fiscal_year(fy)
    fiscal_year(set_child_preference(:selected_fiscal_year, fy)) if fy
  end

  def start_of_first_fiscal_year
    birthdate.next_month.beginning_of_month
  end

  def status(fy)
    Status.new(self, fiscal_year(fy))
  end

  def set_child_preference(key, value)
    user.set_preference(id.to_s => { key => value })
    value
  end

  def child_preference(key, default)
    # logger.debug { "Child preferences args: #{inspect}, #{key}(#{key.class})" }
    # logger.debug { "Child preferences: #{user.preferences}" }
    pref_hash = json(user.preferences)
    # logger.debug { "Child preferences hash: #{pref_hash}" }
    value = (pref_hash && pref_hash[id.to_s] && pref_hash[id.to_s][key.to_s])
    # logger.debug { "Child preferences value before default: #{value}" }
    value ||= default
    # logger.debug { "Child preferences value: #{value}" }
    value
  end

  #-----------------------------------------------------------------------------

  # ----- Private Methods -------------------------------------------------------
  #-----------------------------------------------------------------------------

  private

  def association_in_fiscal_year(association, fy)
    association.select { |x| x.in_fiscal_year?(fy) }
  end

  def fiscal_year_from_year(year)
    start_of_fiscal_year = start_of_first_fiscal_year.change(year: year)
    start_of_fiscal_year -= 1.year if date < start_of_fiscal_year
    FiscalYear.new(start_of_fiscal_year...start_of_fiscal_year.next_year)
  end
end
