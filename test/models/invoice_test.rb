require 'test_helper'

class InvoiceTest < ActiveSupport::TestCase
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that an Invoice.new will create an object
  # => b) tests that the new Invoice instance is of the class Invoice
  # => h) tests that an Invoice instance is invalid even when no funded_person is set
  # => h) tests that an Invoice instance is valid even when no data is set
  # => j) ensure a save is successful if valid? is true
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

    # 01.d .....................................................................
    assert the_inv.save, '01.d: Save of an valid instance should succeed'
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a-h) tests that invoice_from only expected formatted name
  # => i) ensure valid? is true with names set
  # => j) ensure a save is successful if valid? is true
  testName = '02 Check FundedPerson invoice_from method'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_service_provider = 'Services Inc.'
    test_supplier = 'Stuff is Us'
    test_agency = 'CIA'
    the_inv = Invoice.new
    the_inv.funded_person = FundedPerson.first

    # 02.a .....................................................................
    the_inv.service_provider_name = nil
    the_inv.supplier_name = nil
    the_inv.agency_name = nil
    expected = 'No Invoicee Defined'
    assert_equal expected, the_inv.invoice_from, '02.a: invoice_from did not return expected name'

    # 02.b .....................................................................
    the_inv.service_provider_name = test_service_provider
    the_inv.supplier_name = nil
    the_inv.agency_name = nil
    expected = test_service_provider.to_s
    assert_equal expected, the_inv.invoice_from, '02.b: invoice_from did not return expected name'

    # 02.c .....................................................................
    the_inv.service_provider_name = nil
    the_inv.supplier_name = test_supplier
    the_inv.agency_name = nil
    expected = test_supplier.to_s
    assert_equal expected, the_inv.invoice_from, '02.c: invoice_from did not return expected name'

    # 02.d .....................................................................
    the_inv.service_provider_name = test_service_provider
    the_inv.supplier_name = test_supplier
    the_inv.agency_name = nil
    expected = "#{test_service_provider} / #{test_supplier}"
    assert_equal expected, the_inv.invoice_from, '02.d: invoice_from did not return expected name'

    # 02.e .....................................................................
    the_inv.service_provider_name = nil
    the_inv.supplier_name = nil
    the_inv.agency_name = test_agency
    expected = test_agency.to_s
    assert_equal expected, the_inv.invoice_from, '02.e: invoice_from did not return expected name'

    # 02.f .....................................................................
    the_inv.service_provider_name = test_service_provider
    the_inv.supplier_name = nil
    the_inv.agency_name = test_agency
    expected = "#{test_service_provider} / #{test_agency}"
    assert_equal expected, the_inv.invoice_from, '02.f: invoice_from did not return expected name'

    # 02.g .....................................................................
    the_inv.service_provider_name = nil
    the_inv.supplier_name = test_supplier
    the_inv.agency_name = test_agency
    expected = "#{test_agency} / #{test_supplier}"
    assert_equal expected, the_inv.invoice_from, '02.g: invoice_from did not return expected name'

    # 02.h .....................................................................
    the_inv.service_provider_name = test_service_provider
    the_inv.supplier_name = test_supplier
    the_inv.agency_name = test_agency
    expected = "#{test_service_provider} / #{test_agency} / #{test_supplier}"
    assert_equal expected, the_inv.invoice_from, '02.h: invoice_from did not return expected name'

    # 02.i .....................................................................
    assert the_inv.valid?, '02.i: Invoice instance should be valid when name added'

    # 02.j .....................................................................
    assert the_inv.save, '02.j: Save of an valid instance should succeed'
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
    the_inv.service_provider_name = test_service_provider

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
  # This test runs through all records in the fixture where invoice_reference = 'validation test'
  #  It expects there to be one error after running valid?(:complete)
  testName = '04 Check Validation'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    the_invs = Invoice.where(invoice_reference: 'validation test')
    puts "We have #{the_invs.size} test cases"
    expected = 1

    the_invs.each do |tc|
      tc.valid?(:complete)
      ## Diagnostic to show us the errors
      #    This should not be seen unless an unexpected number of errors occur
      unless tc.errors.size == expected
        tc.errors.messages.each do |m|
          puts "Found error: #{m}"
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

  test 'fiscal year' do
    invoice = invoices(:fiscal_year)
    assert_equal '2015-2016', invoice.fiscal_year.to_s
  end

  test 'match no RTPs' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2016-09-30',
                                   service_end: '2016-09-30',
                                   service_start: '2016-09-01',
                                   agency_name: 'A G Ency and Co.',
                                   service_provider_name: 'A Provider')
    assert_equal 0, invoice.match.size
  end

  test 'match one RTP on provider' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2015-08-31',
                                   service_end: '2015-08-31',
                                   service_start: '2015-08-01',
                                   service_provider_name: 'A Provider')
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
                                   agency_name: 'A G Ency and Co.')
    assert_equal 1, invoice.match.size
    assert_equal '2014-07-01 to 2014-09-30',
                 invoice.match[0].service_period_string
  end

  test 'match one RTP on supplier' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2016-03-01',
                                   supplier_name: 'Supplies R Us')
    assert_equal 1, invoice.match.size
    assert_equal '2015-06-01 to 2016-05-31',
                 invoice.match[0].service_period_string
  end

  test 'match two RTPs' do
    child = funded_people(:invoice_to_rtp_match)
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2015-09-30',
                                   service_end: '2015-09-30',
                                   service_start: '2015-09-01',
                                   agency_name: 'A G Ency and Co.',
                                   service_provider_name: 'A Provider')
    assert_equal 2, invoice.match.size
    assert_equal '2015-07-01 to 2015-09-30',
                 invoice.match[0].service_period_string
    assert_equal '2015-09-01 to 2015-09-30',
                 invoice.match[1].service_period_string
  end

  test 'class match no RTPs' do
    params = { invoice_amount: 200,
               invoice_date: '2016-09-30',
               service_end: '2016-09-30',
               service_start: '2016-09-01',
               agency_name: 'A G Ency and Co.',
               service_provider_name: 'A Provider' }
    assert_equal 0, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
  end

  test 'class match one RTP on provider' do
    params = { invoice_amount: 200,
               invoice_date: '2015-08-31',
               service_end: '2015-08-31',
               service_start: '2015-08-01',
               service_provider_name: 'A Provider' }
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
               agency_name: 'A G Ency and Co.' }
    assert_equal 1, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2014-07-01 to 2014-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
  end

  test 'class match one RTP on supplier' do
    params = { invoice_amount: 200,
               invoice_date: '2016-03-01',
               supplier_name: 'Supplies R Us' }
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
               agency_name: 'A G Ency and Co.',
               service_provider_name: 'A Provider' }
    assert_equal 2, Invoice.match(funded_people(:invoice_to_rtp_match),
                                  params).size
    assert_equal '2015-07-01 to 2015-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[0].service_period_string
    assert_equal '2015-09-01 to 2015-09-30',
                 Invoice.match(funded_people(:invoice_to_rtp_match),
                               params)[1].service_period_string
  end
end
