require 'test_helper'
class FundedPersonTest < ActiveSupport::TestCase
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that a FundedPerson.new will create an object
  # => b) tests that the new FundedPerson instance is of the class FundedPerson
  # => c) tests that a FundedPerson instance is invalid if birthdate not set
  # => d) tests that my_dob returns a string of undefined, if birthdate not set
  # => e) tests that a FundedPerson instance is invalid if birthdate set, but in the future
  # => f) tests that a FundedPerson instance is invalid if user not set
  # => g) tests that a FundedPerson instance is invalid if no names are set
  # => h) tests that a FundedPerson instance is valid if birthdate is set and in the past, name is set and user set
  # => i) tests that a valide birthdate can be formatted with my_dob method
  # => j) ensure a save is successful if valid? is true
  testName = '01 Check FundedPerson can be created and saved'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # -- Set up our test variables ---------------------------------------------
    test_birthdate = Time.new('1999-11-15')
    invalid_birthdate = (Time.now + 100_000).strftime('%Y-%m-%d')
    test_user = users(:basic)
    test_date_format_str = '%Y - %m - %d'
    test_last = 'last'

    # 01.a .....................................................................
    the_fp = FundedPerson.new
    assert_not_nil the_fp, '01.a: Instance of FundedPerson Should not be nil'

    # 01.b .....................................................................
    assert_instance_of FundedPerson, the_fp, '01.b: Instance Should be of Class FundedPerson'

    # 01.c .....................................................................
    the_fp.birthdate = nil
    the_fp.user = test_user
    the_fp.name_last = test_last
    assert_not the_fp.valid?, '01.c: FundedPerson instance should not be valid when birthdate not set'

    # 01.d .....................................................................
    the_fp.birthdate = nil
    the_fp.user = test_user
    the_fp.name_last = test_last
    expected = 'undefined'
    assert_equal expected, the_fp.my_dob(test_date_format_str), "01.d: FundedPerson instance my_dob should return #{expected} when birthdate not set"

    # 01.e .....................................................................
    the_fp.birthdate = invalid_birthdate
    the_fp.user = test_user
    the_fp.name_last = test_last
    assert_not the_fp.valid?, '01.e: FundedPerson instance should not be valid when birthdate is invalid'

    # 01.f .....................................................................
    the_fp.birthdate = test_birthdate
    the_fp.user = nil
    the_fp.name_last = test_last
    assert_not the_fp.valid?, '01.f: FundedPerson instance should not be valid when user not set'

    # 01.g .....................................................................
    the_fp.birthdate = invalid_birthdate
    the_fp.user = test_user
    the_fp.name_last = nil
    assert_not the_fp.valid?, '01.g: FundedPerson instance should not be valid when no name is set'

    # 01.h .....................................................................
    the_fp.birthdate = test_birthdate
    the_fp.user = test_user
    the_fp.name_last = test_last
    assert the_fp.valid?, '01.h: FundedPerson instance should be valid when birthdate is valid and a name set'

    # 01.i .....................................................................
    expected = test_birthdate.strftime(test_date_format_str)
    assert_equal expected, the_fp.my_dob(test_date_format_str), "01.i: FundedPerson instance my_dob should return #{expected} when birthdate not set"

    # 01.j .....................................................................
    assert the_fp.save, '01.j: Save of an valid instance should succeed'
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a-h) tests that my_name only expected formatted name
  # => i) ensure valid? is true with names set
  # => j) ensure a save is successful if valid? is true
  testName = '02 Check FundedPerson my_name method'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_first = 'first'
    test_middle = 'middle'
    test_last = 'last'
    test_birthdate = '1999-11-15'
    test_user = users(:basic)
    the_fp = FundedPerson.new
    the_fp.birthdate = test_birthdate
    the_fp.user = test_user

    # 02.a .....................................................................
    the_fp.name_first = nil
    the_fp.name_middle = nil
    the_fp.name_last = nil
    expected = 'no name defined'
    assert_equal expected, the_fp.my_name, '02.a: my_name did not return expected name'

    # 02.b .....................................................................
    the_fp.name_first = test_first
    the_fp.name_middle = nil
    the_fp.name_last = nil
    expected = test_first.to_s
    assert_equal expected, the_fp.my_name, '02.b: my_name did not return expected name'

    # 02.c .....................................................................
    the_fp.name_first = nil
    the_fp.name_middle = test_middle
    the_fp.name_last = nil
    expected = test_middle.to_s
    assert_equal expected, the_fp.my_name, '02.c: my_name did not return expected name'

    # 02.d .....................................................................
    the_fp.name_first = test_first
    the_fp.name_middle = test_middle
    the_fp.name_last = nil
    expected = "#{test_first} #{test_middle}"
    assert_equal expected, the_fp.my_name, '02.d: my_name did not return expected name'

    # 02.e .....................................................................
    the_fp.name_first = nil
    the_fp.name_middle = nil
    the_fp.name_last = test_last
    expected = test_last.to_s
    assert_equal expected, the_fp.my_name, '02.e: my_name did not return expected name'

    # 02.f .....................................................................
    the_fp.name_first = test_first
    the_fp.name_middle = nil
    the_fp.name_last = test_last
    expected = "#{test_first} #{test_last}"
    assert_equal expected, the_fp.my_name, '02.f: my_name did not return expected name'

    # 02.g .....................................................................
    the_fp.name_first = nil
    the_fp.name_middle = test_middle
    the_fp.name_last = test_last
    expected = "#{test_middle} #{test_last}"
    assert_equal expected, the_fp.my_name, '02.g: my_name did not return expected name'

    # 02.h .....................................................................
    the_fp.name_first = test_first
    the_fp.name_middle = test_middle
    the_fp.name_last = test_last
    expected = "#{test_first} #{test_middle} #{test_last}"
    assert_equal expected, the_fp.my_name, '02.h: my_name did not return expected name'

    # 02.i .....................................................................
    assert the_fp.valid?, '02.i: FundedPerson instance should be valid when name added'

    # 02.j .....................................................................
    assert the_fp.save, '02.j: Save of an valid instance should succeed'
  end ## -- end test --

  test 'Fiscal year beginning of year' do
    child = funded_people(:beginning_of_year)
    assert_equal Time.new(2009, 2, 1).to_date..Time.new(2010, 1, 31).to_date,
                 child.fiscal_year(Time.new(2010, 1, 1))
  end

  test 'Fiscal year end of year' do
    child = funded_people(:end_of_year)
    assert_equal Time.new(2013, 1, 1).to_date..Time.new(2013, 12, 31).to_date,
                 child.fiscal_year(Time.new(2013, 1, 1))
  end

  test 'Fiscal year beginning of month' do
    child = funded_people(:beginning_of_month)
    assert_equal Time.new(2009, 5, 1).to_date..Time.new(2010, 4, 30).to_date,
                 child.fiscal_year(Time.new(2010, 1, 1))
  end

  test 'Fiscal year end of month' do
    child = funded_people(:end_of_month)
    assert_equal Time.new(2016, 5, 1).to_date..Time.new(2017, 4, 30).to_date,
                 child.fiscal_year(Time.new(2016, 12, 31))
  end

  test 'Fiscal year end of month on birthday' do
    child = funded_people(:end_of_month)
    assert_equal Time.new(2015, 5, 1).to_date..Time.new(2016, 4, 30).to_date,
                 child.fiscal_year(Time.new(2016, 4, 30))
  end

  test 'Leap year on birthday no leap day' do
    child = funded_people(:leap_day)
    assert_equal Time.new(2008, 3, 1).to_date..Time.new(2009, 2, 28).to_date,
                 child.fiscal_year(Time.new(2009, 2, 28))
  end

  test 'Leap year on birthday leap day' do
    child = funded_people(:leap_day)
    assert_equal Time.new(2007, 3, 1).to_date..Time.new(2008, 2, 29).to_date,
                 child.fiscal_year(Time.new(2008, 2, 29))
  end

  test 'fiscal years list' do
    child = funded_people(:no_fiscal_years)
    assert_equal 0, child.fiscal_years.count

    child = funded_people(:one_fiscal_year)
    assert_equal 1, child.fiscal_years.count
    assert_equal ['2017'], child.fiscal_years.map(&:to_s)

    child = funded_people(:two_fiscal_years)
    assert_equal %w(2016-2017 2015-2016), child.fiscal_years.map(&:to_s)
    assert_equal 2, child.fiscal_years.count
  end

  test 'fiscal year with form and invoice' do
    child = funded_people(:invoice_and_form)
    assert_equal 2, child.fiscal_years.count
    assert_equal %w(2016-2017 2015-2016), child.fiscal_years.map(&:to_s)
  end

  test 'cf0925s in fiscal year' do
    child = funded_people(:two_fiscal_years)
    assert_equal 3, child.cf0925s.size
    assert_equal 1,
                 child.cf0925s_in_fiscal_year(FiscalYear.new(child.fiscal_year(Date.new(2016, 1, 1)))).size
    assert_equal 2,
                 child.cf0925s_in_fiscal_year(FiscalYear.new(child.fiscal_year(Date.new(2017, 1, 1)))).size
  end

  test 'invoices in fiscal year' do
    child = funded_people(:two_fiscal_years)
    assert_equal 1, child.invoices.size
    assert_equal 1,
                 child.invoices_in_fiscal_year(FiscalYear.new(child.fiscal_year(Date.new(2016, 1, 1)))).size
    assert_equal 0,
                 child.invoices_in_fiscal_year(FiscalYear.new(child.fiscal_year(Date.new(2017, 1, 1)))).size
  end
end

# the_fp.errors.messages.each do |m|
#  puts "**Line: #{__LINE__}: An error: #{m}"
# end
