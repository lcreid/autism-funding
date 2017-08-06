require "test_helper"
require "helpers/invoices_test_helper.rb"

class InvoicesTest < PoltergeistTest
  include TestSessionHelpers
  #  include TestInvoiceAllocationHelpers
  include ActionView::Helpers::NumberHelper

  test "invoice with one valid RTP" do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button "New Invoice"

    assert_current_path new_funded_person_invoice_path(child)

    select "Joe 2016", from: "invoice_invoice_from"
    fill_in "Amount", with: "200.00"
    fill_in "Service Start", with: "2017-01-01"
    start_request

    fill_in "Service End", with: "2017-01-31"
    wait_for_request

    assert_selector ".test-cf0925-table"

    assert_selector "tr.test-cf0925-invoice-row", count: 1
    # TODO: Make sure I've retrieved the right ones.
    # assert has_select?('Request to Pay',
    #                    with_options: ['Out of Pocket',
    #                                   'Joe 2016 2016-07-01 to 2017-06-14'],
    #                    selected: 'Joe 2016 2016-07-01 to 2017-06-14')
    # expect has_select?('Request to Pay',
    #                    selected: 'Joe 2016 2016-07-01 to 2017-06-14')
    click_link_or_button "Save"

    assert_content "Invoice saved."
  end

  test "invoice with two valid RTPs" do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button "New Invoice"
    assert_current_path new_funded_person_invoice_path(child)

    # start_request
    select "Joe 2016", from: "invoice_invoice_from"
    # wait_for_request
    # start_request
    fill_in "Amount", with: "200.00"
    # wait_for_request
    # start_request
    fill_in "Service Start", with: "2016-07-01"
    # wait_for_request
    start_request
    fill_in "Service End", with: "2016-07-31"
    wait_for_request

    assert_selector ".test-cf0925-table"
    assert_selector "tr.test-cf0925-invoice-row", count: 2
    # TODO: Make sure I've retrieved the right ones.
    click_link_or_button "Save"
    assert_content "Invoice saved."

    click_link "My Home"

    find(".invoice-list td", text: "Joe 2016")
      .find(:xpath, "..")
      .click_link "Edit"
    assert_selector "tr.test-cf0925-invoice-row", count: 2
    # TODO: Make sure I've retrieved the right ones.
  end

  test "invoice with no matching RTPs" do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button "New Invoice"
    assert_current_path new_funded_person_invoice_path(child)

    assert_no_selector "tr.test-cf0925-invoice-row"
    assert_content "No RTPs match this invoice,"
    select "Joe 2016", from: "invoice_invoice_from"
    fill_in "Amount", with: "400.00"
    fill_in "Service Start", with: "2015-07-01"
    start_request
    fill_in "Service End", with: "2015-07-31"
    wait_for_request

    assert_no_selector "tr.test-cf0925-invoice-row"
    assert_content "No RTPs match this invoice,"
    # puts body
    # puts find_field(type: 'number').value
    # all('input').each { |x| puts "#{x.tag_name} id=#{x['id']}: #{x.value}" }
    assert_selector '#invoice_out_of_pocket'
    assert_field "Amount"
    assert_field "Service Start", with: "2015-07-01"
    assert_field "Service End", with: "2015-07-31"
    # assert_field '#invoice_out_of_pocket' # , visible: :all, with: 400
    # puts "Out of Pocket: #{find_field('Out of Pocket', disabled: true).value}"
    assert_field "Out of Pocket", disabled: true, with: "400.00"

    click_link_or_button "Save"
    assert_content "Invoice saved."
  end

  test "get invoice page with one RTP" do
    fill_in_login(user = users(:invoice_with_rtp_matched))
    # TODO: Figure out Devise and where to go on login
    # TODO: The following should be the home page path
    assert_current_path "/"

    visit edit_invoice_path(invoice = user.funded_people.first.invoices.first)
    assert_current_path edit_invoice_path(invoice)

    assert_selector "tr.test-cf0925-invoice-row", count: 1
  end

  test "assign invoice allocations and return to edit" do
    fill_in_login(user = users(:invoice_with_rtp_matched))
    assert_current_path "/"

    child = user.funded_people.first
    invoice = child.invoices.first

    visit edit_invoice_path(invoice)
    assert_selector "tr.test-cf0925-invoice-row", count: 1
    within find("tr.test-cf0925-invoice-row") do
      fill_in("Amount", with: 200)
    end

    click_link_or_button "Save"

    visit edit_invoice_path(invoice)
    assert_selector "tr.test-cf0925-invoice-row", count: 1
    within find("tr.test-cf0925-invoice-row") do
      # puts "Invoice allocation amount 149ish: #{find_field('Amount').value}"
      assert_field("Amount", with: "200.00")
    end
  end

  test "check invoice allocations after change of matching" do
    child = set_up_child
    user = child.user
    rtp_2000 = set_up_provider_agency_rtp(child,
      service_provider_service_amount: 2000)

    chk_rtp_2000 = MyProfileTestHelper::CheckRTP.new

    user.save
    fill_in_login(user)

    # Create New Invoice and Initialize
    assert_current_path "/"
    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button "New Invoice"
    assert_current_path new_funded_person_invoice_path(child)

    chk_rtp_2000.amount_requested = rtp_2000.service_provider_service_amount
    fill_in "invoice_invoice_amount", with: 2222
    chk_rtp_2000.set_invoice_fields_to_match_rtp rtp_2000

    #-----------------------------------------------------------------------------
    chk_rtp_2000.set_amount_from_this_invoice 45.56
    chk_rtp_2000.set_expected_amount 45.56
    chk_rtp_2000.set_expected_amount_available (rtp_2000.service_provider_service_amount - 45.56)
    chk_rtp_2000.set_expected_out_of_pocket 2176.44
    # -- Check results
    assert_check_invoice_allocations [chk_rtp_2000]

    #-----------------------------------------------------------------------------
    # We will save this, which will cause the allocations to be saved
    # We come back to the page, unmatch the RTP and then Match RTP, then save
    # When we come back to the page we expect to see our RTP
    click_link_or_button "Save"
    assert_current_path "/"
    # Now Go Back and edit
    user.reload
    visit edit_invoice_path(child.invoices.first)

    # TODO: Need to look at the who formats what on the edit page.  I needed to
    # reset the values merely so they will be formatted consistently

    chk_rtp_2000.set_amount_from_this_invoice 45.56
    chk_rtp_2000.set_expected_amount 45.56
    chk_rtp_2000.set_expected_amount_available (rtp_2000.service_provider_service_amount - 45.56)
    chk_rtp_2000.set_expected_out_of_pocket 2176.44

    assert_check_invoice_allocations [chk_rtp_2000]

    # unmatch the invoice
    start_request
    chk_rtp_2000.set_invoice_fields_to_not_match_rtp rtp_2000
    wait_for_request

    # we now expect no allocations
    assert_check_invoice_allocations

    # Rematch the invoice
    start_request
    chk_rtp_2000.set_invoice_fields_to_match_rtp rtp_2000
    wait_for_request

    # Save
    click_link_or_button "Save"
    assert_current_path "/"

    # Now Go Back and edit
    user.reload
    visit edit_invoice_path(child.invoices.first)

    #--- Check that there is only one invoice
    chk_rtp_2000.set_expected_amount "0.00"
    chk_rtp_2000.set_expected_amount_available "$2,000", ""
    chk_rtp_2000.set_expected_out_of_pocket "2,222.00", ""

    # puts "HERE [#{chk_rtp_2000.expected_amount}]"
    # puts "HERE [#{chk_rtp_2000.expected_amount_available}]"
    # puts "HERE [#{chk_rtp_2000.expected_out_of_pocket}]"

    # puts "OUT OF POCKET: #{find_field('Out of Pocket', disabled: true).value}"
    # puts "chk_rtp_2000.expected_amount: #{chk_rtp_2000.expected_amount}"
    assert_check_invoice_allocations [chk_rtp_2000]
  end

  test 'javascript validations Issue #65' do
    child = set_up_child
    user = child.user
    rtp_2000 = set_up_provider_agency_rtp(child,
      service_provider_service_amount: 2000)
    rtp_3000 = set_up_provider_agency_rtp(child,
      service_provider_service_amount: 3000)
    invoice = child
              .invoices
              .build(invoice_from: rtp_2000.agency_name,
                     service_start: rtp_2000.service_provider_service_start,
                     invoice_amount: 1500)
    user.save!
    user.reload

    assert_equal 2, child.cf0925s.size
    assert_equal 1, child.invoices.size
    assert_equal 2, child.invoices.first.match.size, "No match found"

    fill_in_login(user)
    assert_current_path "/"

    # puts 'About to go to invoice page'
    visit edit_invoice_path(invoice)
    # puts 'Went to invoice page'
    # Filling in something to force a match.
    # This is a hack to make the way we set up the test data work.
    fill_in "Service End",
      with: rtp_2000.service_provider_service_end
    assert_selector "tr.test-cf0925-invoice-row", count: 2

    # Set up some useful variables
    (allocation_2000, allocation_3000) = sort_out_allocation_rows

    # Test that triggers no corrections
    test_amount = invoice.invoice_amount / 2
    within allocation_2000 do
      find(".amount-available")
        .assert_text "%.2f" % rtp_2000
                              .service_provider_service_amount
      fill_in("Amount", with:  test_amount)
      assert_field("Amount", with: "%.2f" % test_amount)
      find(".amount-available")
        .assert_text "%.2f" % (rtp_2000
          .service_provider_service_amount - test_amount)
    end
    assert_field("Out of Pocket",
      disabled: true,
      with: number_to_currency((invoice.invoice_amount - test_amount), unit: ""))

    #
    # Test that changing amount causes requiste change in out-of-pocket and amount available
    within allocation_2000 do
      find(".amount-available")
        .assert_text "%.2f" % (rtp_2000
          .service_provider_service_amount - test_amount)

      # Change test_amount
      test_amount -= 2
      fill_in("Amount", with:  test_amount)
      assert_field("Amount", with: "%.2f" % test_amount)
      find(".amount-available")
        .assert_text "%.2f" % (rtp_2000
          .service_provider_service_amount - test_amount)

      # put test amount back, or rest of tests will fail
      test_amount += 2
      fill_in("Amount", with:  test_amount)
    end
    assert_field("Out of Pocket",
      disabled: true,
      with: number_to_currency((invoice.invoice_amount - test_amount), unit: ""))

    # Amount allocated greater than invoice amount minus other allocation
    # Depends on above
    within allocation_3000 do
      find(".amount-available")
        .assert_text "%.2f" % rtp_3000
                              .service_provider_service_amount
      fill_in("Amount", with: invoice.invoice_amount / 2 + 1)
      assert_field("Amount", with: number_to_currency(invoice.invoice_amount / 2, unit: ""))
      find(".amount-available")
        .assert_text "%.2f" % (rtp_3000
          .service_provider_service_amount - invoice.invoice_amount / 2)
    end
    assert_field("Out of Pocket",
      disabled: true,
      with: "0.00")

    # Amount allocated greater than amount available after other invoices
    # Need to make another invoice.

    click_link_or_button "Save"
    assert_current_path "/"

    invoice = child
              .invoices
              .create(invoice_from: rtp_2000.agency_name,
                      #                    service_start: rtp_2000.service_provider_service_start,
                      invoice_amount: 2250)
    user.reload
    # puts "rtp_2000.invoice_allocations.first.amount_available: #{rtp_2000.invoice_allocations.first.amount_available}"
    # puts "rtp_2000.invoice_allocations.last.amount_available: #{rtp_2000.invoice_allocations.last.amount_available}"
    # puts "invoice.match.size: #{invoice.match.size}"

    visit edit_invoice_path(invoice)

    # Filling in something to force a match.
    fill_in "Service End",
      with: rtp_2000.service_provider_service_end
    assert_selector "tr.test-cf0925-invoice-row", count: 2

    # Set up some useful variables

    (allocation_2000, allocation_3000) = sort_out_allocation_rows

    # Test that changing amount by a small amount correctly recalulates amount available
    within allocation_2000 do
      find(".amount-available").assert_text "%.2f" % 1250
      fill_in("Amount", with: 2)
      assert_field("Amount", with: "%.2f" % 2)
      find(".amount-available").assert_text "%.2f" % 1248
    end
    assert_field("Out of Pocket",
      disabled: true,
      with: "%.2f" % 2248)

    within allocation_2000 do
      find(".amount-available").assert_text "%.2f" % 1248
      fill_in("Amount", with: 2000)
      assert_field("Amount", with: "%.2f" % 1250)
      find(".amount-available").assert_text "%.2f" % 0
    end
    assert_field("Out of Pocket",
      disabled: true,
      with: "%.2f" % 1000)

    within allocation_2000 do
      fill_in("Amount", with: 1249)
      assert_field("Amount", with: "%.2f" % 1249)
      find(".amount-available").assert_text "%.2f" % 1
    end
    assert_field("Out of Pocket",
      disabled: true,
      with: "%.2f" % 1001)
  end

  private

  def sort_out_allocation_rows
    allocation_row_1 = find("tr.test-cf0925-invoice-row:first-of-type")
    allocation_row_2 = find("tr.test-cf0925-invoice-row:last-of-type")
    if allocation_row_1.find("td:nth-of-type(4)").text == "$2,000.00"
      return allocation_row_1, allocation_row_2
    else
      return allocation_row_2, allocation_row_1
    end
  end

  def assert_check_invoice_allocations(ary = [])
    # Check we are on the Edit or New invoice page
    assert_content "Assign Request to Pay"
    # Check we have the expected number of matched RTPs
    assert_selector "tr.test-cf0925-invoice-row", count: ary.size

    ary.each do |allocation_row|
      within allocation_row.allocation_row do
        find(".amount-available")
          .assert_text allocation_row.expected_amount_available # , "Unexpected Amount Available"
        # puts "#{__LINE__}: expected amount: #{allocation_row.expected_amount}"
        # puts "#{__LINE__}: amount: #{find_field('Amount').value}"
        assert_field("Amount", with: allocation_row.expected_amount)
      end
      # puts "#{__LINE__}: expected out of pocket: #{allocation_row.expected_out_of_pocket}"
      assert_field("Out of Pocket",
        disabled: true,
        with: allocation_row.expected_out_of_pocket)
    end
  end
end
