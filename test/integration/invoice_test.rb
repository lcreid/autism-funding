require 'test_helper'

class InvoiceTest < PoltergeistTest
  include TestSessionHelpers

  test 'invoice with one valid RTP' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    assert_selector("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'
    assert_current_path new_funded_person_invoice_path(child)

    select 'Joe 2016', from: 'invoice_service_provider_name'
    fill_in 'invoice_invoice_amount', with: '200.00'
    fill_in 'invoice_service_start', with: '2017-01-01'
    fill_in 'invoice_service_end', with: '2017-01-31'

    assert_select 'invoice_cf0925', selected: 'Joe 2016 2016-07-01 to 2017-06-14'
    click_link_or_button 'Save'
    assert_content 'Invoice saved.'
  end

  test 'invoice with two valid RTPs' do
    fill_in_login(users(:years))
    child = funded_people(:two_fiscal_years)

    click_link child.my_name
    # It looks like you need to check that the tab actually opened, to give
    # the Javascript time to execute.
    assert_selector("#collapse-#{child.id}.in")
    click_link_or_button 'New Invoice'
    assert_current_path new_funded_person_invoice_path(child)

    select 'Joe 2016', from: 'invoice_service_provider_name'
    fill_in 'invoice_invoice_amount', with: '200.00'
    fill_in 'invoice_service_start', with: '2016-07-01'
    fill_in 'invoice_service_end', with: '2016-07-31'

    assert_select 'invoice_cf0925', selected: []

    select 'Joe 2016 2016-07-01 to 2016-08-31', from: 'invoice_cf0925'
    click_link_or_button 'Save'
    assert_content 'Invoice saved.'
  end
end
