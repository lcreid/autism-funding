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
    expected = 'No invoicee defined'
    assert_equal expected, the_inv.invoice_from, '02.a: invoice_from did not return expected name'

    # 02.b .....................................................................
    the_inv.service_provider_name = test_service_provider
    the_inv.supplier_name = nil
    the_inv.agency_name = nil
    expected = "#{test_service_provider}"
    assert_equal expected, the_inv.invoice_from, '02.b: invoice_from did not return expected name'

    # 02.c .....................................................................
    the_inv.service_provider_name = nil
    the_inv.supplier_name = test_supplier
    the_inv.agency_name = nil
    expected = "#{test_supplier}"
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
      expected = "#{test_agency}"
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
    expected = "#{test_supplier} / #{test_agency}"
    assert_equal expected, the_inv.invoice_from, '02.g: invoice_from did not return expected name'

    # 02.h .....................................................................
    the_inv.service_provider_name = test_service_provider
    the_inv.supplier_name = test_supplier
    the_inv.agency_name = test_agency
    expected = "#{test_service_provider} / #{test_supplier} / #{test_agency}"
    assert_equal expected, the_inv.invoice_from, '02.h: invoice_from did not return expected name'

    # 02.i .....................................................................
    assert the_inv.valid?, '02.i: Invoice instance should be valid when name added'

    # 02.j .....................................................................
    assert the_inv.save, '02.j: Save of an valid instance should succeed'
  end ## -- end test --
end
