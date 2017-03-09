require 'test_helper'

class InvoicesTest < PoltergeistTest
  include TestSessionHelpers
  include ActionView::Helpers::NumberHelper

  test 'invoice with one valid RTP' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'

    assert_current_path new_funded_person_invoice_path(child)

    select 'Joe 2016', from: 'invoice_invoice_from'
    fill_in 'Amount', with: '200.00'
    fill_in 'Service Start', with: '2017-01-01'
    start_request

    fill_in 'Service End', with: '2017-01-31'
    wait_for_request

    assert_selector '.test-cf0925-table'

    assert_selector 'tr.test-cf0925-invoice-row', count: 1
    # TODO: Make sure I've retrieved the right ones.
    # assert has_select?('Request to Pay',
    #                    with_options: ['Out of Pocket',
    #                                   'Joe 2016 2016-07-01 to 2017-06-14'],
    #                    selected: 'Joe 2016 2016-07-01 to 2017-06-14')
    # expect has_select?('Request to Pay',
    #                    selected: 'Joe 2016 2016-07-01 to 2017-06-14')
    click_link_or_button 'Save'

    assert_content 'Invoice saved.'
  end

  test 'invoice with two valid RTPs' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'
    assert_current_path new_funded_person_invoice_path(child)

    # start_request
    select 'Joe 2016', from: 'invoice_invoice_from'
    # wait_for_request
    # start_request
    fill_in 'Amount', with: '200.00'
    # wait_for_request
    # start_request
    fill_in 'Service Start', with: '2016-07-01'
    # wait_for_request
    start_request
    fill_in 'Service End', with: '2016-07-31'
    wait_for_request

    assert_selector '.test-cf0925-table'
    assert_selector 'tr.test-cf0925-invoice-row', count: 2
    # TODO: Make sure I've retrieved the right ones.
    click_link_or_button 'Save'
    assert_content 'Invoice saved.'

    click_link 'My Home'

    find('.invoice-list td', text: 'Joe 2016')
      .find(:xpath, '..')
      .click_link 'Edit'
    assert_selector 'tr.test-cf0925-invoice-row', count: 2
    # TODO: Make sure I've retrieved the right ones.
  end

  test 'invoice with no matching RTPs' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'
    assert_current_path new_funded_person_invoice_path(child)

    assert_no_selector 'tr.test-cf0925-invoice-row'
    assert_content 'No RTPs match this invoice,'
    select 'Joe 2016', from: 'invoice_invoice_from'
    fill_in 'Amount', with: '400.00'
    fill_in 'Service Start', with: '2015-07-01'
    start_request
    fill_in 'Service End', with: '2015-07-31'
    wait_for_request

    assert_no_selector 'tr.test-cf0925-invoice-row'
    assert_content 'No RTPs match this invoice,'
    # puts body
    # puts find_field(type: 'number').value
    # all('input').each { |x| puts "#{x.tag_name} id=#{x['id']}: #{x.value}" }
    assert_selector '#invoice_out_of_pocket'
    assert_field 'Amount'
    assert_field 'Service Start', with: '2015-07-01'
    assert_field 'Service End', with: '2015-07-31'
    # assert_field '#invoice_out_of_pocket' # , visible: :all, with: 400
    puts "Out of Pocket: #{find_field('Out of Pocket', disabled: true).value}"
    assert_field 'Out of Pocket', disabled: true, with: '400.00'

    click_link_or_button 'Save'
    assert_content 'Invoice saved.'
  end

  test 'get invoice page with one RTP' do
    fill_in_login(user = users(:invoice_with_rtp_matched))
    # TODO: Figure out Devise and where to go on login
    # TODO: The following should be the home page path
    assert_current_path '/'

    visit edit_invoice_path(invoice = user.funded_people.first.invoices.first)
    assert_current_path edit_invoice_path(invoice)

    assert_selector 'tr.test-cf0925-invoice-row', count: 1
  end

  test 'assign invoice allocations and return to edit' do
    fill_in_login(user = users(:invoice_with_rtp_matched))
    assert_current_path '/'

    child = user.funded_people.first
    invoice = child.invoices.first

    visit edit_invoice_path(invoice)
    assert_selector 'tr.test-cf0925-invoice-row', count: 1
    within find('tr.test-cf0925-invoice-row') do
      fill_in('Amount', with: 200)
    end

    click_link_or_button 'Save'

    visit edit_invoice_path(invoice)
    assert_selector 'tr.test-cf0925-invoice-row', count: 1
    within find('tr.test-cf0925-invoice-row') do
      # puts "Invoice allocation amount 149ish: #{find_field('Amount').value}"
      assert_field('Amount', with: '200.00')
    end
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
    assert_equal 2, child.invoices.first.match.size, 'No match found'

    fill_in_login(user)
    assert_current_path '/'

    puts 'About to go to invoice page'
    visit edit_invoice_path(invoice)
    puts 'Went to invoice page'
    # Filling in something to force a match.
    # This is a hack to make the way we set up the test data work.
    fill_in 'Service End',
            with: rtp_2000.service_provider_service_end
    assert_selector 'tr.test-cf0925-invoice-row', count: 2

    # Set up some useful variables
    (allocation_2000, allocation_3000) = sort_out_allocation_rows

    # Test that triggers no corrections
    within allocation_2000 do
      find('.amount-available')
        .assert_text '%.2f' % (rtp_2000
          .service_provider_service_amount)
      fill_in('Amount', with: invoice.invoice_amount / 2)
      assert_field('Amount', with: invoice.invoice_amount / 2)
      find('.amount-available')
        .assert_text '%.2f' % (rtp_2000
          .service_provider_service_amount - invoice.invoice_amount / 2)
    end
    assert_field('Out of Pocket',
                 disabled: true,
                 with: number_to_currency(invoice.invoice_amount / 2, unit: ''))

    # Amount allocated greater than invoice amount minus other allocation
    # Depends on above
    within allocation_3000 do
      find('.amount-available')
        .assert_text '%.2f' % (rtp_3000
          .service_provider_service_amount)
      fill_in('Amount', with: invoice.invoice_amount / 2 + 1)
      assert_field('Amount', with: number_to_currency(invoice.invoice_amount / 2, unit: ''))
      find('.amount-available')
        .assert_text '%.2f' % (rtp_3000
          .service_provider_service_amount - invoice.invoice_amount / 2)
    end
    assert_field('Out of Pocket',
                 disabled: true,
                 with: '0.00')

    # Amount allocated greater than amount available after other invoices
    # Need to make another invoice.

    click_link_or_button 'Save'
    assert_current_path '/'

    invoice = child
              .invoices
              .create(invoice_from: rtp_2000.agency_name,
  #                    service_start: rtp_2000.service_provider_service_start,
                      invoice_amount: 2250)
    user.reload
    puts "rtp_2000.invoice_allocations.first.amount_available: #{rtp_2000.invoice_allocations.first.amount_available}"
    puts "rtp_2000.invoice_allocations.last.amount_available: #{rtp_2000.invoice_allocations.last.amount_available}"
puts "invoice.match.size: #{invoice.match.size}"

    visit edit_invoice_path(invoice)

    # Filling in something to force a match.
    fill_in 'Service End',
            with: rtp_2000.service_provider_service_end
    assert_selector 'tr.test-cf0925-invoice-row', count: 2

    # Set up some useful variables

    (allocation_2000, allocation_3000) = sort_out_allocation_rows

    within allocation_2000 do
      find('.amount-available').assert_text '%.2f' % (1250)
      fill_in('Amount', with: 2000)
      assert_field('Amount', with: 1250)
      find('.amount-available').assert_text '%.2f' % (0)
    end
    assert_field('Out of Pocket',
                 disabled: true,
                 with: number_to_currency(1000, unit: ''))

    within allocation_2000 do
      fill_in('Amount', with: 1249)
      assert_field('Amount', with: 1249)
      find('.amount-available').assert_text number_to_currency(1)
    end
    assert_field('Out of Pocket',
                 disabled: true,
                 with: number_to_currency(1001, unit: ''))
  end

  private

  def sort_out_allocation_rows
    allocation_row_1 = find('tr.test-cf0925-invoice-row:first-of-type')
    allocation_row_2 = find('tr.test-cf0925-invoice-row:last-of-type')
    if allocation_row_1.find('td:nth-of-type(4)').text == '$2,000.00'
      return allocation_row_1, allocation_row_2
    else
      return allocation_row_2, allocation_row_1
    end
  end
end
