require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that an Invoice.new will create an object
  # => b) tests that the new Invoice instance is of the class Invoice
  # => c) tests that an Invoice instance is invalid when no funded_person is set
  # => d) tests that an Invoice instance is valid when no data is set, but funded_person is assigned
  # => e) ensure a save is successful if valid? is true
  testName = '01 Check Invoice can be created and saved'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # -- Set up our test variables ---------------------------------------------
    the_funded_person = FundedPerson.first

    # 01.a .....................................................................
    the_inv = Invoice.new
    assert_not_nil the_inv, '01.a: Instance of Invoice Should not be nil'

    # 01.b .....................................................................
    assert_instance_of Invoice, the_inv, '01.b: Instance Should be of Class Invoice'

    # 01.c .....................................................................
    assert_not the_inv.valid?, '01.c: Invoice instance should be invalid with no FundedPerson set'
    #    the_inv.errors.messages.each do |m|
    #     puts "**Line: #{__LINE__}: An error: #{m}"
    #    end

    # 01.d .....................................................................
    the_inv.funded_person = the_funded_person
    assert the_inv.valid?, '01.d: Invoice instance should be valid with FundedPerson set'

    # 01.e .....................................................................
    assert the_inv.save, '01.e: Save of an valid instance should succeed'
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a) tests that invoice_from can be set
  # => b) ensure valid? is true with invoice_from set
  # => c) ensure a save is successful if valid? is true
  testName = '02 Check FundedPerson invoice_from'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_invoice_from = 'Services Inc.'
    the_inv = Invoice.new
    the_inv.funded_person = FundedPerson.first

    # 02.a .....................................................................
    the_inv.invoice_from = test_invoice_from
    expected = test_invoice_from
    assert_equal expected, the_inv.invoice_from, '02.a: invoice_from did not return expected invoice_from'

    # 02.b .....................................................................
    assert the_inv.valid?, '02.b: Invoice instance should be valid when invoice_from_assigned'

    # 02.c .....................................................................
    assert the_inv.save, '02.c: Save of an valid instance should succeed'
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 03
  # => a) tests that start_date returns nil if no dates defined
  # => b) tests that start_date returns service_end if only service_end defined
  # => c) tests that start_date returns invoice_date if service_end & invoice_date defined
  # => d) tests that start_date returns service_start if service_start, service_end & invoice_date defined
  testName = '03 Check start_date method'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_service_provider = 'Services Inc.'
    test_supplier = 'Stuff is Us'
    test_agency = 'CIA'
    the_inv = Invoice.new
    the_inv.funded_person = FundedPerson.first

    test_invoice_date = Date.new(2005, 03, 11)
    test_service_start = Date.new(2005, 02, 01)
    test_service_end = Date.new(2005, 03, 01)

    # 03.a .....................................................................
    the_inv.invoice_date = nil
    the_inv.invoice_from = test_service_provider

    the_inv.service_start = nil
    the_inv.service_end = nil
    assert_nil the_inv.start_date, '03.a: start_date should be nil if no dates defined'

    # 03.b .....................................................................
    the_inv.invoice_date = nil
    the_inv.service_start = nil
    the_inv.service_end = test_service_end
    expected = test_service_end
    assert_equal expected, the_inv.start_date, '03.b: start_date should return service_end if only service_end defined'

    # 03.c .....................................................................
    the_inv.invoice_date = test_invoice_date
    the_inv.service_start = nil
    the_inv.service_end = test_service_end
    expected = test_invoice_date
    assert_equal expected, the_inv.start_date, '03.c: start_date should return service_start if invoice_date and service_end defined'

    # 03.d .....................................................................
    the_inv.invoice_date = test_invoice_date
    the_inv.service_start = test_service_start
    the_inv.service_end = test_service_end
    expected = test_service_start
    assert_equal expected, the_inv.start_date, '03.d: start_date should return service_start if service_start, invoice_date and service_end defined'
  end

  #-----------------------------------------------------------------------------
  #  Test 04
  #    Tests validations on: :complete
  # This test runs through all records in the fixture where invoice_reference = 'create one validation error'
  #  It expects there to be one error after running valid?(:complete)
  testName = '04 Check Validation'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    the_invs = Invoice.where(invoice_reference: 'Create 1 :complete Validation Error')
    puts ""
    puts "We have #{the_invs.size} test cases"
    expected = 1

    the_invs.each do |tc|
      tc.valid?(:complete)
      ## Diagnostic to show us the errors
      #    This should not be seen unless an unexpected number of errors occur
      unless tc.errors.size == expected
        pp tc
        puts "Start FY: #{tc.funded_person.fiscal_year(tc.service_start)}"
        puts "End FY: #{tc.funded_person.fiscal_year(tc.service_end)}"
        puts ""
        tc.errors.messages.each do |m|
          puts "Found error: #{m} for #{tc.notes}"
        end

      end

      assert_equal expected, tc.errors.size, "04: Test for #{tc.notes}"

      # check that include_in_reports? is false
      assert_not tc.include_in_reports?, "04: include_in_reports? is true after Test for #{tc.notes}"
    end

    ##- One final test to make sure that a complete form has no errors and include_in_reports? is true
    the_inv = invoices(:inv_valtest_complete)
    assert_equal 0, the_inv.errors.size, "04: Test for #{the_inv.notes}"
    assert the_inv.include_in_reports?, "04: include_in_reports? is not true after Test for #{the_inv.notes}"
  end


  #-----------------------------------------------------------------------------
  #  Set of tests to check Validations and include_in_reports?
  testName = 'Validation Check, Invoice Completed with Invoice Date'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date1 = '2017-01-01'
    test_case = {invoice_date: date1,
                  invoice_from: 'Anin Voicer',
                  invoice_amount: 150}
    test_checks = {complete: true, include: true, error_size: 0, start_date: date1}
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Completed with Service Start'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date2 = '2017-01-08'
    test_case = {service_start: date2,
                  invoice_from: 'Anin Voicer',
                  invoice_amount: 150}
    test_checks = {complete: true, include: true, error_size: 0, start_date: date2}
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Completed with Service End'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date3 = '2017-01-31'
    test_case = {service_start: date3,
                  invoice_from: 'Anin Voicer',
                  invoice_amount: 150}
    test_checks = {complete: true, include: true, error_size: 0, start_date: date3}
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Date but no Amount'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date1 = '2017-01-01'
    test_case = {invoice_date: date1,
                  invoice_from: 'Anin Voicer'
                  }
    test_checks = {complete: false, include: false, error_size: 1, errors: {invoice_amount: "can't be blank"}, start_date: date1}
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Date but no Invoice From'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date1 = '2017-01-01'
    test_case = {invoice_date: date1,
                  invoice_amount: 150
                  }
    test_checks = {complete: false, include: false, error_size: 1, errors: {invoice_from: "can't be blank"}, start_date: date1}
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, No Dates provided'
  test testName do
    # puts "-- Test: #{testName} ------------"
    test_case = {invoice_from: 'Anin Voicer',
                  invoice_amount: 150
                  }
    err_hash = {invoice_date: "must supply at least one date",
                service_start: "must supply at least one date",
                service_end: "must supply at least one date"}
    test_checks = {complete: false, include: false, error_size: 3, errors: err_hash}
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Service end before start'
  test testName do
    date2 = '2017-01-08'
    date3 = '2017-01-01'
    # puts "-- Test: #{testName} ------------"
    test_case = {invoice_from: 'Anin Voicer',
                  invoice_amount: 150,
                  service_start: date2,
                  service_end: date3
                  }
    err_hash = {service_end: "service end cannot be earlier than service start"}
    test_checks = {complete: false, include: false, error_size: 1, errors: err_hash}
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Service end not in same FY as start'
  test testName do
    date2 = '2017-01-08'
    date3 = '2018-01-09'
    # puts "-- Test: #{testName} ------------"
    test_case = {invoice_from: 'Anin Voicer',
                  invoice_amount: 150,
                  service_start: date2,
                  service_end: date3
                  }
    err_hash = {service_end: "must be in the same fiscal year as service start"}
    test_checks = {complete: false, include: false, error_size: 1, errors: err_hash}
    assert_status '', test_case, test_checks
  end

  test 'fiscal year' do
    invoice = invoices(:fiscal_year)
    assert_equal '2015-2016', invoice.fiscal_year.to_s
  end

  # Cf0925.yml has the following RTPs for the child :invoice_to_rtp_match
  # | # | Service Provider |        Agency        |      Supplier     |   Start    |    End     |
  # | a | A Provider       | A G Ency and Co.     |                   | 2015-07-01 | 2015-09-30 |
  # | b |                  |                      | Supplies R Us     |            |            |
  # | c | A Provider       | A G Ency and Co.     |                   | 2015-09-01 | 2015-09-30 |
  # | d | Not A Provider   | Not A G Ency and Co. |                   | 2015-07-01 | 2015-09-30 |
  # | e |                  |                      | Not Supplies R Us |            |            |
  # | f | A Provider       | A G Ency and Co.     |                   | 2014-07-01 | 2014-09-30 |
  # | g | A Provider       |                      |                   | 2017-07-01 | 2017-09-30 |
  # | h |                  | A G Ency and Co.     |                   | 2017-10-01 | 2017-12-31 |

  test 'match no RTPs on Provider' do
    # This test invoice should have 0 matches at the dates are not in range
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2016-09-30',
                                   service_end: '2016-09-30',
                                   service_start: '2016-09-01',
                                   invoice_from: 'A Provider')
    assert_equal 0, invoice.match.size
  end

  test 'match no RTPs on Agency' do
    # This test invoice should have 0 matches at the dates are not in range
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2016-09-30',
                                   service_end: '2016-09-30',
                                   service_start: '2016-09-01',
                                   invoice_from: 'A G Ency and Co.')
    assert_equal 0, invoice.match.size
  end

  test 'match one RTP on provider' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2015-08-31',
                                   service_end: '2015-08-31',
                                   service_start: '2015-08-01',
                                   invoice_from: 'A Provider')
    assert_equal 1, invoice.match.size
    assert_equal '2015-07-01 to 2015-09-30',
                 invoice.match[0].service_period_string
  end

  test 'match one RTP on agency' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2014-08-31',
                                   service_end: '2014-08-31',
                                   service_start: '2014-08-01',
                                   invoice_from: 'A G Ency and Co.')
    assert_equal 1, invoice.match.size
    assert_equal '2014-07-01 to 2014-09-30',
                 invoice.match[0].service_period_string
  end

  test 'match one RTP on supplier' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2016-03-01',
                                   invoice_from: 'Supplies R Us')
    assert_equal 1, invoice.match.size
    assert_equal '2015-06-01 to 2016-05-31',
                 invoice.match[0].service_period_string
  end

  test 'match two RTPs on Provider' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2015-09-30',
                                   service_end: '2015-09-30',
                                   service_start: '2015-09-01',
                                   invoice_from: 'A Provider')
    assert_equal 2, invoice.match.size
    assert_equal '2015-07-01 to 2015-09-30',
                 invoice.match[0].service_period_string
    assert_equal '2015-09-01 to 2015-09-30',
                 invoice.match[1].service_period_string
  end

  test 'match two RTPs on Agency' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2015-09-30',
                                   service_end: '2015-09-30',
                                   service_start: '2015-09-01',
                                   invoice_from: 'A G Ency and Co.')
    assert_equal 2, invoice.match.size
    assert_equal '2015-07-01 to 2015-09-30',
                 invoice.match[0].service_period_string
    assert_equal '2015-09-01 to 2015-09-30',
                 invoice.match[1].service_period_string
  end

  test 'allocation two RTPs' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2015-09-30',
                                   service_end: '2015-09-30',
                                   service_start: '2015-09-01',
                                   invoice_from: 'A Provider')
    assert_equal(2, (rtps = invoice.match).size)

    invoice.allocate(rtps)
    assert_equal(2, invoice.invoice_allocations.size)

    # The records don't get joined in both directions until they're saved.
    # rtps.each { |rtp| assert_equal(1, rtp.invoices.size) }
    assert_difference 'InvoiceAllocation.count', 2 do
      invoice.save
    end
    assert_equal(2, invoice.cf0925s.size)
    rtps.each { |rtp| assert_equal(1, rtp.invoices.size) }
  end

  test 'class match no RTPs on Provider' do
    params = { invoice_amount: 200,
               invoice_date: '2016-09-30',
               service_end: '2016-09-30',
               service_start: '2016-09-01',
               invoice_from: 'A Provider' }
    assert_equal 0, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
  end

  test 'class match no RTPs on Agency' do
    params = { invoice_amount: 200,
               invoice_date: '2016-09-30',
               service_end: '2016-09-30',
               service_start: '2016-09-01',
               invoice_from: 'A G Ency and Co.' }
    assert_equal 0, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
  end

  test 'class match one RTP on provider' do
    params = { invoice_amount: 200,
               invoice_date: '2015-08-31',
               service_end: '2015-08-31',
               service_start: '2015-08-01',
               invoice_from: 'A Provider' }
    assert_equal 1, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2015-07-01 to 2015-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
  end

  test 'class match one RTP on agency' do
    params = { invoice_amount: 200,
               invoice_date: '2014-08-31',
               service_end: '2014-08-31',
               service_start: '2014-08-01',
               invoice_from: 'A G Ency and Co.' }
    assert_equal 1, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2014-07-01 to 2014-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
  end

  test 'class match one RTP on supplier' do
    params = { invoice_amount: 200,
               invoice_date: '2016-03-01',
               invoice_from: 'Supplies R Us' }
    assert_equal 1, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2015-06-01 to 2016-05-31',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
  end

  test 'class match two RTPs' do
    params = { invoice_amount: 200,
               invoice_date: '2015-09-30',
               service_end: '2015-09-30',
               service_start: '2015-09-01',
               #  agency_name: 'A G Ency and Co.',
               invoice_from: 'A Provider' }
    assert_equal 2, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2015-07-01 to 2015-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
    assert_equal '2015-09-01 to 2015-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[1].service_period_string
  end

  test 'class match RTP with provider only and no payment specified' do
    params = { invoice_amount: 200,
               invoice_date: '2017-08-31',
               service_end: '2017-08-31',
               service_start: '2017-08-01',
               invoice_from: 'A Provider' }
    assert_equal 1, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2017-07-01 to 2017-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
  end

  test 'class match RTP with agency only and no payment specified' do
    params = { invoice_amount: 200,
               invoice_date: '2017-11-30',
               service_end: '2017-11-30',
               service_start: '2017-11-01',
               invoice_from: 'A G Ency and Co.' }
    assert_equal 1, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2017-10-01 to 2017-12-31',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
  end
  #--- Private Methods ---------------------------------------------------------
  private

  def assert_status(msg, cases, chks)
    inv = Invoice.new
    inv.funded_person = FundedPerson.first
    inv.update(cases)

    # pp inv
    #pp chks

    # Check that the results are as expected
    chks.each do |chk, val|
      case chk
      when :complete
        assert_equal  val, inv.valid?(:complete), "#{msg}: Invoice object has unexpected valid?(:complete)"
      when :error_size
        inv.valid?(:complete)
        show_errors inv unless inv.errors.messages.size == val
        assert_equal val, inv.errors.messages.size, "#{msg}: Invoice object had an unexpected number of errors"
      when :include
        assert_equal val, inv.include_in_reports?, "#{msg}: Invoice object has unexpected include_in_reports?"
      when :errors
        inv.valid?(:complete)
        val.each do |item, message|
          found = false
          inv.errors.each do |i, m|
            found = true if (item == i && message == m)
          end
          show_errors inv unless found
          assert found, "#{msg}: could not find error message #{message} for #{item} in #{inv.errors.messages.size} errors"
        end
      when :start_date
        assert_equal val, inv.start_date.to_s, "#{msg}Invoice object had an unexpected start date"
      end
    end
  end

  def show_errors obj
    puts "Number of Errors: #{obj.errors.messages.size}"
    obj.errors.messages.each do |m|
      puts "  **Error: #{m}"
    end

  end
end
