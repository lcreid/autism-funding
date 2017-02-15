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
    puts ''
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
        puts ''
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
    test_case = { invoice_date: date1,
                  invoice_from: 'Anin Voicer',
                  invoice_amount: 150 }
    test_checks = { complete: true, include: true, error_size: 0, start_date: date1 }
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Completed with Service Start'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date2 = '2017-01-08'
    test_case = { service_start: date2,
                  invoice_from: 'Anin Voicer',
                  invoice_amount: 150 }
    test_checks = { complete: true, include: true, error_size: 0, start_date: date2 }
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Completed with Service End'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date3 = '2017-01-31'
    test_case = { service_start: date3,
                  invoice_from: 'Anin Voicer',
                  invoice_amount: 150 }
    test_checks = { complete: true, include: true, error_size: 0, start_date: date3 }
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Date but no Amount'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date1 = '2017-01-01'
    test_case = { invoice_date: date1,
                  invoice_from: 'Anin Voicer'
                  }
    test_checks = { complete: false, include: false, error_size: 1, errors: { invoice_amount: "can't be blank" }, start_date: date1 }
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Invoice Date but no Invoice From'
  test testName do
    # puts "-- Test: #{testName} ------------"
    date1 = '2017-01-01'
    test_case = { invoice_date: date1,
                  invoice_amount: 150
                  }
    test_checks = { complete: false, include: false, error_size: 1, errors: { invoice_from: "can't be blank" }, start_date: date1 }
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, No Dates provided'
  test testName do
    # puts "-- Test: #{testName} ------------"
    test_case = { invoice_from: 'Anin Voicer',
                  invoice_amount: 150
                  }
    err_hash = { invoice_date: 'must supply at least one date',
                 service_start: 'must supply at least one date',
                 service_end: 'must supply at least one date' }
    test_checks = { complete: false, include: false, error_size: 3, errors: err_hash }
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Service end before start'
  test testName do
    date2 = '2017-01-08'
    date3 = '2017-01-01'
    # puts "-- Test: #{testName} ------------"
    test_case = { invoice_from: 'Anin Voicer',
                  invoice_amount: 150,
                  service_start: date2,
                  service_end: date3
                  }
    err_hash = { service_end: 'service end cannot be earlier than service start' }
    test_checks = { complete: false, include: false, error_size: 1, errors: err_hash }
    assert_status '', test_case, test_checks
  end

  testName = 'Validation Check, Service end not in same FY as start'
  test testName do
    date2 = '2017-01-08'
    date3 = '2018-01-09'
    # puts "-- Test: #{testName} ------------"
    test_case = { invoice_from: 'Anin Voicer',
                  invoice_amount: 150,
                  service_start: date2,
                  service_end: date3
                  }
    err_hash = { service_end: 'must be in the same fiscal year as service start' }
    test_checks = { complete: false, include: false, error_size: 1, errors: err_hash }
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
    assert_equal(2, (matches = invoice.match).size)

    invoice.allocate(matches)
    assert_equal(2, invoice.invoice_allocations.size)

    # The records don't get joined in both directions until they're saved.
    # matches.map(&:cf0925).each { |rtp| assert_equal(1, rtp.invoices.size) }
    assert_difference 'InvoiceAllocation.count', 2 do
      invoice.save
    end
    assert_equal(2, invoice.cf0925s.size)
    matches.map(&:cf0925).each { |rtp| assert_equal(1, rtp.invoices.size) }
  end

  test 'invoice has no allocations, allocate one new RTP' do
    child = set_up_child
    match = Match.new('Supplier', set_up_supplier_rtp(child))
    invoice = child.invoices.build
    invoice.allocate(match)
    # puts "invoice: #{invoice.object_id}"
    # puts "invoice.invoice_allocations: #{invoice.invoice_allocations.inspect}"
    # puts "object_id: #{invoice.invoice_allocations.first.object_id}"
    # invoice.save
    assert_invoice_allocation_equal [match], invoice.invoice_allocations
  end

  test 'invoice has two existing allocations, ' \
        'allocate one new, and only one existing RTP' do
    child = set_up_child
    existing_match_that_should_be_saved = Match.new('Supplier',
                                                    set_up_supplier_rtp(child))
    existing_match_that_should_be_deleted = Match.new('Supplier',
                                                      set_up_supplier_rtp(child))
    invoice = child.invoices.build

    invoice.allocate([existing_match_that_should_be_saved,
                      existing_match_that_should_be_deleted])
    # invoice.save

    # puts "invoice.invoice_allocations.size: #{invoice.invoice_allocations.size}"
    assert_invoice_allocation_equal [existing_match_that_should_be_saved,
                                     existing_match_that_should_be_deleted],
                                    invoice.invoice_allocations

    new_match = Match.new('Supplier', set_up_supplier_rtp(child))
    invoice.allocate([existing_match_that_should_be_saved, new_match])
    # invoice.save

    assert_invoice_allocation_equal [existing_match_that_should_be_saved,
                                     new_match], invoice.invoice_allocations
  end

  test 'invoice has allocation of part A RTP, ' \
        'allocate the same RTP, but matched on part B' do
    child = set_up_child
    part_a_match = Match.new('ServiceProvider',
                             set_up_provider_agency_rtp(child))
    invoice = child.invoices.build

    invoice.allocate(part_a_match)
    # puts "part_a_match object_id #{part_a_match.object_id}"
    # invoice.save
    # puts "part_a_match object_id #{part_a_match.object_id}"

    assert_invoice_allocation_equal [part_a_match], invoice.invoice_allocations

    # TODO: Make Match initializer take an existing match
    part_b_match = Match.new('Supplier', part_a_match.cf0925)
    invoice.allocate(part_b_match)
    # invoice.save

    assert_invoice_allocation_equal [part_b_match], invoice.invoice_allocations
  end

  test 'invoice has allocation of part A RTP, ' \
        'allocate the same RTP, but matched on part A and B' do
    child = set_up_child
    part_a_match = Match.new('ServiceProvider',
                             set_up_provider_agency_rtp(child))
    invoice = child.invoices.build

    invoice.allocate(part_a_match)
    # invoice.save

    assert_invoice_allocation_equal [part_a_match], invoice.invoice_allocations

    part_a_match.cf0925.assign_attributes(SUPPLIER_ATTRS)

    part_a_and_b_match = Match.new('Supplier',
                                   set_up_provider_agency_rtp(child,
                                                              SUPPLIER_ATTRS))
    invoice.allocate([part_a_match, part_a_and_b_match])
    # invoice.save

    assert_invoice_allocation_equal [part_a_match,
                                     part_a_and_b_match],
                                    invoice.invoice_allocations
  end

  test 'get two matches for one pair of invoice and RTP' do
    child = set_up_child
    both_parts_rtp = set_up_provider_agency_rtp(child,
                                                SUPPLIER_ATTRS
                                                  .merge(supplier_name:
                                                  'Pay Me Agency'))
    invoice = child.invoices.build(invoice_amount: 200,
                                   invoice_date: '2017-02-28',
                                   service_end: '2017-02-28',
                                   service_start: '2017-01-01',
                                   invoice_from: 'Pay Me Agency')
    matches = invoice.match
    assert_equal 2, matches.size
    assert_invoice_allocation_equal [both_parts_rtp, both_parts_rtp],
                                    matches.map(&:cf0925)
    invoice.allocate(matches)
    assert_equal 2, invoice.invoice_allocations.size
  end

  # PART A MATCHING --Agency or provider name matches printable RTP with
  # part A completed
  test 'no dates provided part A' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.agency_name)
    assert_match_part_a [], invoice
  end

  test 'service start and end within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.service_provider_name,
                                   service_start:
                                     rtp.service_provider_service_start,
                                   service_end:
                                     rtp.service_provider_service_end)
    assert_match_part_a [rtp], invoice
  end

  test 'service start and end not within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.agency_name,
                                   service_start:
                                     rtp.service_provider_service_start,
                                   service_end:
                                     rtp.service_provider_service_end + 1.day)
    assert_match_part_a [], invoice
  end

  test 'no service start, service end within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.service_provider_name,
                                   service_end:
                                     rtp.service_provider_service_end)
    assert_match_part_a [rtp], invoice
  end

  test 'no service start, service end not within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.agency_name,
                                   service_end:
                                     rtp.service_provider_service_start - 1.day)
    assert_match_part_a [], invoice
  end

  test 'no service end, service start within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.service_provider_name,
                                   service_start:
                                     rtp.service_provider_service_end)
    assert_match_part_a [rtp], invoice
  end

  test 'no service end, service start not within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.agency_name,
                                   service_start:
                                     rtp.service_provider_service_end + 1.day)
    assert_match_part_a [], invoice
  end

  test 'no service start or end, invoice date within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.service_provider_name,
                                   invoice_date:
                                     rtp.service_provider_service_start)
    assert_match_part_a [rtp], invoice
  end

  test 'no service start or end, invoice date not within service period of RTP' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.agency_name,
                                   invoice_date:
                                     rtp.service_provider_service_start - 1.day)
    assert_match_part_a [], invoice
  end

  # PART A MATCHING -- Other tests
  test 'neither service provider name nor agency name in printable RTP ' \
       'match invoice from' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    invoice = child.invoices.build(invoice_from:
                                    rtp.agency_name + 'x',
                                   invoice_date:
                                     rtp.service_provider_service_start)
    assert_match_part_a [], invoice
  end

  test 'service provider or agency name matches invoice from ' \
       'and dates within RTP service period, but RTP not printable' do
    child = set_up_child
    rtp = set_up_provider_agency_rtp(child)
    rtp.service_provider_address = nil
    invoice = child.invoices.build(invoice_from:
                                    rtp.service_provider_name,
                                   invoice_date:
                                     rtp.service_provider_service_start)
    assert_match_part_a [], invoice
  end

  # PART B MATCHING -- Supplier name matches printable RTP with part B completed
  test 'no dates provided part B' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name)
    assert_match_part_b [], invoice
  end

  test 'invoice date in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   invoice_date: rtp.part_b_fiscal_year.begin)
    assert_match_part_b [rtp], invoice
  end

  test 'invoice date not in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   invoice_date: rtp.part_b_fiscal_year.begin - 1.day)
    assert_match_part_b [], invoice
  end

  test 'service end is only date and in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   service_end: rtp.part_b_fiscal_year.begin)
    assert_match_part_b [rtp], invoice
  end

  test 'service end is only date and not in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   service_end: rtp.part_b_fiscal_year.end + 1.day)
    assert_match_part_b [], invoice
  end

  test 'service start is only date and in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   service_start: rtp.part_b_fiscal_year.begin)
    assert_match_part_b [rtp], invoice
  end

  test 'service start is only date and not in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   service_start: rtp.part_b_fiscal_year.begin - 1.day)
    assert_match_part_b [], invoice
  end

  test 'no invoice date service start and service end in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   service_start: rtp.part_b_fiscal_year.begin,
                                   service_end: rtp.part_b_fiscal_year.end)
    assert_match_part_b [rtp], invoice
  end

  test 'no invoice date service start and service end not in part B fiscal year of RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   service_start: rtp.part_b_fiscal_year.begin,
                                   service_end: rtp.part_b_fiscal_year.end + 1.day)
    assert_match_part_b [], invoice
  end

  # PART B MATCHING -- Other tests
  test 'supplier name does not match invoice date in printable RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    invoice = child.invoices.build(invoice_from: rtp.supplier_name + 'x',
                                   service_start: rtp.part_b_fiscal_year.begin,
                                   service_end: rtp.part_b_fiscal_year.end)
    assert_match_part_b [], invoice
  end

  test 'supplier name matches, invoice date in non-printable RTP' do
    child = set_up_child
    rtp = set_up_supplier_rtp(child)
    rtp.supplier_city = nil
    invoice = child.invoices.build(invoice_from: rtp.supplier_name,
                                   service_start: rtp.part_b_fiscal_year.begin)
    assert_match_part_b [], invoice
  end

  #--- Private Methods ---------------------------------------------------------

  private

  def assert_invoice_allocation_equal(expected, actual, msg = nil)
    # puts 'assert_inv... ' \
    # "#{expected.sort_by(&:object_id).map(&:inspect)}, " \
    # "#{actual.sort_by(&:object_id).map(&:inspect)}"
    # if expected.sort_by(&:object_id) != actual.sort_by(&:object_id)
    #   puts 'Expected'
    #   expected.each_with_index do |x, i|
    #     puts "#{i}: x.class.name #{x.class.name} x.cf0925.object_id #{x.cf0925.object_id}"
    #   end
    #   puts 'Actual'
    #   actual.each_with_index do |x, i|
    #     puts "#{i}: x.class.name #{x.class.name} x.cf0925.object_id #{x.cf0925.object_id}"
    #   end
    # end

    assert_equal expected, actual, msg
  end

  def assert_match_part_a(expected_rtps, invoice, msg = {})
    assert_match 'ServiceProvider', expected_rtps, invoice, msg
  end

  def assert_match_part_b(expected_rtps, invoice, msg = {})
    assert_match 'Supplier', expected_rtps, invoice, msg
  end

  def assert_match(type, expected_rtps, invoice, msg = {})
    expected_matches = expected_rtps.map { |rtp| Match.new(type, rtp) }
    # puts 'EXPECTED'
    # puts expected_matches.each { |x| puts x.object_id }
    # puts 'ACTUAL'
    # puts invoice.match.each { |x| puts x.object_id }
    assert_equal expected_matches, invoice.match, msg
  end

  def assert_status(msg, cases, chks)
    inv = Invoice.new
    inv.funded_person = FundedPerson.first
    inv.update(cases)

    # pp inv
    # pp chks

    # Check that the results are as expected
    chks.each do |chk, val|
      case chk
      when :complete
        assert_equal val, inv.valid?(:complete), "#{msg}: Invoice object has unexpected valid?(:complete)"
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
            found = true if item == i && message == m
          end
          show_errors inv unless found
          assert found, "#{msg}: could not find error message #{message} for #{item} in #{inv.errors.messages.size} errors"
        end
      when :start_date
        assert_equal val, inv.start_date.to_s, "#{msg}Invoice object had an unexpected start date"
      end
    end
  end

  def show_errors(obj)
    puts "Number of Errors: #{obj.errors.messages.size}"
    obj.errors.messages.each do |m|
      puts "  **Error: #{m}"
    end
  end
end
