require 'test_helper'

class StatusTest < ActiveSupport::TestCase
  test 'status one year' do
    child = funded_people(:two_fiscal_years)
    status_2016 = child.status('2015-2016')
    assert_equal 200, status_2016.spent_funds
    assert_equal 2_500, status_2016.committed_funds
    assert_equal 3_500, status_2016.remaining_funds
    assert_equal 0, status_2016.spent_out_of_pocket
  end

  test 'status next year' do
    child = funded_people(:two_fiscal_years)
    status_2017 = child.status('2016-2017')
    assert_equal 0, status_2017.spent_funds
    assert_equal 3_000, status_2017.committed_funds
    assert_equal 3_000, status_2017.remaining_funds
    assert_equal 0, status_2017.spent_out_of_pocket
  end

  test 'statuses are different' do
    child = funded_people(:two_fiscal_years)
    status_2016 = child.status('2015-2016')
    status_2017 = child.status('2016-2017')
    assert_not_equal status_2016, status_2017
  end

  test 'child under 6' do
    child = funded_people(:four_year_old)
    status = child.status('2016-2017')
    assert_equal 22_000, status.allowable_funds_for_year
  end

  test 'child 6 and over' do
    child = funded_people(:sixteen_year_old)
    status = child.status(child.fiscal_year(Date.new(2016, 6, 1)))
    assert_equal 6_000, status.allowable_funds_for_year
  end

  test 'too old for funding' do
    child = funded_people(:sixteen_year_old)
    status = child.status(child.fiscal_year(Date.new(2018, 6, 1)))
    assert_equal 0, status.allowable_funds_for_year
  end

  test 'not born yet' do
    child = funded_people(:four_year_old)
    status = child.status(child.fiscal_year(Date.new(2012, 2, 29)))
    assert_equal 0, status.allowable_funds_for_year
  end

  test 'big spender' do
    skip
  end
end
