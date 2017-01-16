require 'test_helper'

class InvoicesTest < PoltergeistTest
  include TestSessionHelpers

  test 'invoice with one valid RTP' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'
    assert_current_path new_funded_person_invoice_path(child)

    select 'Joe 2016', from: 'invoice_service_provider_name'
    fill_in 'Amount', with: '200.00'
    fill_in 'Service Start', with: '2017-01-01'
    start_request
    fill_in 'Service End', with: '2017-01-31'
    wait_for_request

    assert has_select?('Request to Pay',
                       with_options: ['Out of Pocket',
                                      'Joe 2016 2016-07-01 to 2017-06-14'],
                       selected: 'Joe 2016 2016-07-01 to 2017-06-14')
    # expect has_select?('Request to Pay',
    #                    selected: 'Joe 2016 2016-07-01 to 2017-06-14')
    click_link_or_button 'Save'
    assert_content 'Invoice saved.'
  end

  test 'invoice with two valid RTPs' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)
    # puts "Child: #{child.inspect} Number of RTPs: #{child.cf0925s.size}"

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'
    assert_current_path new_funded_person_invoice_path(child)

    start_request
    select 'Joe 2016', from: 'invoice_service_provider_name'
    wait_for_request
    start_request
    fill_in 'Amount', with: '200.00'
    wait_for_request
    start_request
    fill_in 'Service Start', with: '2016-07-01'
    wait_for_request
    start_request
    fill_in 'Service End', with: '2016-07-31'
    wait_for_request

    select 'Joe 2016 2016-07-01 to 2016-08-30', from: 'Request to Pay'
    click_link_or_button 'Save'
    assert_content 'Invoice saved.'

    click_link 'My Home'
    find('.invoice-list td', text: 'Joe 2016')
      .find(:xpath, '..')
      .click_link 'Edit'
    expect has_select?('Request to Pay',
                       selected: 'Joe 2016 2016-07-01 to 2016-08-30')
  end

  test 'invoice with no valid RTPs' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    expect has_selector?("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'
    assert_current_path new_funded_person_invoice_path(child)

    select 'Joe 2016', from: 'invoice_service_provider_name'
    fill_in 'Amount', with: '400.00'
    fill_in 'Service Start', with: '2015-07-01'
    start_request
    fill_in 'Service End', with: '2015-07-31'
    wait_for_request

    expect has_select?('Request to Pay', selected: 'Out of Pocket')

    click_link_or_button 'Save'
    assert_content 'Invoice saved.'
  end
end
