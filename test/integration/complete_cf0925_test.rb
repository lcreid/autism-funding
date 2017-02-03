require 'test_helper'

class CompleteCf0925Test < CapybaraTest
  include TestSessionHelpers

  fixtures :forms
  fixtures :funded_people

  def setup
    @form_field_values = {
      agency_name: 'agency_name',
      child_dob: '2002-05-14',
      child_first_name: 'child_first_name',
      child_last_name: 'child_last_name',
      child_middle_name: 'child_middle_name',
      child_in_care_of_ministry: false,
      home_phone: 'home_phone',
      item_cost_1: 10,
      item_cost_2: 20,
      item_cost_3: 30,
      item_desp_1: 'item_desp_1',
      item_desp_2: 'item_desp_2',
      item_desp_3: 'item_desp_3',
      parent_address: 'parent_address',
      parent_city: 'parent_city',
      parent_first_name: 'parent_first_name',
      parent_last_name: 'parent_last_name',
      parent_middle_name: 'parent_middle_name',
      parent_postal_code: 'parent_postal_code',
      part_b_fiscal_year: '2016-2017',
      payment: 'agency',
      service_provider_postal_code: 'service_provider_postal_code',
      service_provider_address: 'service_provider_address',
      service_provider_city: 'service_provider_city',
      service_provider_phone: 'service_provider_phone',
      service_provider_name: 'service_provider_name',
      service_provider_service_1: 'service_provider_service_1',
      service_provider_service_2: 'service_provider_service_2',
      service_provider_service_3: 'service_provider_service_3',
      service_provider_service_amount: 2000,
      service_provider_service_end: '2017-05-31',
      service_provider_service_fee: 150,
      service_provider_service_hour: 'service_provider_service_hour',
      service_provider_service_start: '2016-06-01',
      supplier_address: 'supplier_address',
      supplier_city: 'supplier_city',
      supplier_contact_person: 'supplier_contact_person',
      supplier_name: 'supplier_name',
      supplier_phone: 'supplier_phone',
      supplier_postal_code: 'supplier_postal_code',
      work_phone: 'work_phone',
      form_id: forms(:cf0925).id,
      funded_person_id: (@funded_person = funded_people(:cf0925)).id
    }
  end

  test 'CF_0925 autofill from user and child' do
    fill_in_login(users(:has_no_rtp))
    click_link 'New Request to Pay'

    assert_difference 'Cf0925.count' do
      click_button 'Save'
    end

    click_link 'Edit'
    assert has_no_link?('Print'), "Shouldn't have 'Print' link"

    {
      agency_name: 'autofill user and child',
      item_cost_1: 10,
      item_cost_2: 20,
      item_cost_3: 30,
      item_desp_1: 'Tablet',
      item_desp_2: 'Phone',
      item_desp_3: 'Notebook',
      part_b_fiscal_year: '2016-2017',
      payment_agency: '',
      service_provider_postal_code: 'N1N 1N1',
      service_provider_address: '22222 Main St.',
      service_provider_city: 'Vancouver',
      service_provider_phone: '555-555-2345',
      service_provider_name: 'Joe B. Consultant',
      service_provider_service_1: 'Behaviour consulting',
      service_provider_service_amount: 2000,
      service_provider_service_end: '2017-11-30',
      service_provider_service_fee: 150,
      service_provider_service_start: '2016-12-01',
      supplier_address: '11111 Main St.',
      supplier_city: 'Vancouver',
      supplier_name: 'ABBA Learning',
      supplier_phone: '555-555-1234',
      supplier_postal_code: 'N0N 0N0'
    }.each do |k, v|
      set_field(k, v)
    end
    select 'Hour', from: 'cf0925_service_provider_service_hour'

    assert_no_difference 'Cf0925.count' do
      click_button 'Save'
    end

    click_link 'Edit'

    assert_equal 200, status_code
    assert(rtp = Cf0925.find_by(agency_name: 'autofill user and child'),
           'Could not find record')
    assert_current_path edit_cf0925_path(rtp)
    assert rtp.printable?, rtp.errors.full_messages

    if ENV['TEST_PDF_GENERATION']
      click_link 'Print'
      assert_current_path cf0925_path(rtp, :pdf)
      # page.driver.close_window(page.driver.current_window_handle)
    else
      puts 'Skipped PDF generation. To include: `export TEST_PDF_GENERATION=1`'
    end
    # click_link_or_button 'Home'
    # assert_current_path home_index_path
  end

  test 'RTP for dual-child parent' do
    user = users(:dual_child_parent)

    fill_in_login user
    assert_title(Globals.site_name + ' All Children')

    child = all('.child .name', count: 2)
    assert_equal 'Four Year Two-Kids', child[0].text
    assert_equal 'Sixteen Year Two-Kids', child[1].text

    within '.child:first-of-type' do
      # puts "WTF? WTF? #{find('.name').text}" unless find('.name').text == 'Four Year Two-Kids'
      click_link 'New Request to Pay'
    end

    assert_content 'Section 1 Parent/Guardian Information'

    # assert_field works on the label, so if you don't have a label, it won't
    # work. It also doesn't use the ID, but rather the "for=" attribute.
    # This was for when the fields were fillable. We decided you have to go
    # back to the profile page to do that.
    assert_field 'Last Name', with: 'Two-Kids'
    assert_field 'First', with: 'I'
    # assert_field 'cf0925_child_first_name', with: 'Sixteen'
    # assert_selector '#parent_last_name', text: 'Two-Kids'
    # assert_selector '#parent_first_name', text: 'I'
    # puts find('label[for="cf0925_child_first_name"] + p').text
    assert_selector 'label[for="cf0925_child_first_name"] + p', text: 'Four'
  end

  test 'Change parent info' do
    create_a_cf0925
  end

  test 'Edit an existing CF0925' do
    create_a_cf0925

    within 'table.form-list tbody tr:last-of-type' do
      click_link 'Edit'
    end
    new_city = 'Vernon'
    within '.parent-address-fields' do
      fill_in 'City', with: new_city
    end
    assert_no_difference 'Cf0925.count' do
      assert_no_difference 'FundedPerson.count' do
        assert_no_difference 'User.count' do
          assert_no_difference 'Address.count' do
            assert_no_difference 'PhoneNumber.count' do
              click_button 'Save'
            end
          end
        end
      end
    end

    assert Address.find_by(city: new_city), "City in address not #{new_city}"
  end

  test 'put a form in the list and edit it' do
    fill_in_login(users(:forms))
    click_link 'All Forms'
    assert_equal 1, all('.static-form-record').size
    assert_content 'Request to Pay'
    assert_content 'Ready to Print'
    assert_content 'service_provider_name'
    assert_content '$3,000'

    click_link 'Edit'
    assert_button 'Save'
  end

  test 'delete a form' do
    create_a_cf0925
    assert_current_path home_index_path
    assert_difference 'Cf0925.count', -1 do
      assert_no_difference 'User.count' do
        assert_no_difference 'FundedPerson.count' do
          within 'table.form-list tbody tr:first-of-type' do
            click_link 'Delete'
          end
        end
      end
    end
  end

  test 'part A or part B message' do
    user = users(:has_no_rtp)
    fill_in_login user

    click_link 'New Request to Pay'
    within '#base-errors' do
      assert_content 'Fill in Part A or Part B or both.'
    end
  end

  test 'edit a cf0925 with invalid postal code' do
    create_a_cf0925
    edit_last_cf0925
    set_parent_postal_code 'VVV 000'
    click_button 'Save'
    assert_selector 'form.edit_cf0925'
    # puts bodys
    assert parent_postal_code_has_error?
    # all('div.form-group input').each { |x| puts x.value }
    assert_selector 'div.has-error', count: 10
  end

  test 'edit a cf0925 with invalid home phone' do
    create_a_cf0925
    edit_last_cf0925
    set_home_phone_number '60455566667'
    click_button 'Save'
    assert_selector 'form.edit_cf0925'
    assert home_phone_number_has_error?
    assert_selector 'div.has-error', count: 10
  end

  test 'edit a cf0925 with invalid work phone' do
    create_a_cf0925
    edit_last_cf0925
    set_work_phone_number '60455566667'
    click_button 'Save'
    assert_selector 'form.edit_cf0925'
    assert work_phone_number_has_error?
    assert_selector 'div.has-error', count: 10
  end

  test 'create and edit a cf0925 with part B fiscal year' do
    create_a_part_b_cf0925(part_b_fiscal_year: '2015')
    edit_last_cf0925
    set_part_b_fiscal_year '2016'
    click_button 'Save'
    edit_last_cf0925
    assert_selector 'form.edit_cf0925'
    # There's no errors because part B isn't filled in yet.
    assert_no_selector 'div.has-error'
  end

  private

  def create_a_cf0925
    address = '9999 Secondary St'
    middle_name = 'Charles'
    phone_number = '(999) 999-9999'

    fill_in_login(users(:forms))
    click_link 'New Request to Pay'
    assert_difference 'Cf0925.count' do
      assert_no_difference 'User.count' do
        # assert_difference 'PhoneNumber.count' do
        fill_in 'Middle', with: middle_name
        # puts find('.parent-test')['innerHTML']
        within '.parent-test' do
          fill_in 'Address', with: address
          # puts 'Phones: ' + all(:fillable_field, 'Phone').inspect
          # all(:fillable_field, 'Home Phone').each do |e|
          #   puts e[:id]
          # end
          fill_in 'Home Phone', with: phone_number
        end
        # I shouldn't really need the following.
        fill_in 'cf0925_service_provider_service_start', with: '2016-08-01'
        fill_in 'cf0925_service_provider_service_end', with: '2016-09-30'
        choose 'cf0925_payment_provider'
        click_button 'Save'
        # end
      end
    end

    assert has_link? 'Home'
    # assert has_link? 'Edit'
    # puts "Middle name from user: #{user.name_middle}"
    # user.reload
    # puts "Middle name from user: #{user.name_middle}"
    assert PhoneNumber.find_by(phone_number: '9999999999'),
           'PhoneNumber not updated'
    assert Cf0925.find_by(home_phone: phone_number),
           'Phone in RTP not updated'
    assert User.find_by(name_middle: middle_name), 'Parent not updated'
    assert Cf0925.find_by(service_provider_service_start: '2016-08-01'),
           'Start date in RTP not updated'
    assert Cf0925.find_by(parent_middle_name: middle_name), 'Parent middle name in RTP not updated'
    assert Address.find_by(address_line_1: address), 'Address not updated'
    assert Cf0925.find_by(parent_address: address), 'Address in RTP not updated'
  end

  def create_a_part_b_cf0925(fields = {})
    fill_in_login(users(:forms))
    click_link 'New Request to Pay'
    assert_difference 'Cf0925.count' do
      assert_no_difference 'User.count' do
        fields.each do |k, v|
          set_field(k, v)
        end

        click_button 'Save'
      end
    end
  end

  def edit_last_cf0925
    find('table.form-list tbody tr:first-of-type').click_link('Edit')
  end

  def home_phone_number_has_error?
    # find('div.parent-test div.has-error').find_field('Postal Code')
    find('#cf0925_funded_person_attributes_user_attributes_home_phone_number + span.help-block')
    true
  rescue Capybara::ElementNotFound => e
    puts e.inspect
    false
  end

  # Don't need this because you can't select an invalid value from a select
  # def part_b_fiscal_year_has_error?
  #   find('#cf0925_part_b_fiscal_year + span.help-block')
  #   true
  # rescue Capybara::ElementNotFound => e
  #   puts e.inspect
  #   false
  # end

  def parent_postal_code_has_error?
    find('#cf0925_funded_person_attributes_user_attributes_postal_code + span.help-block')
    true
  rescue Capybara::ElementNotFound => e
    puts e.inspect
    false
  end

  def work_phone_number_has_error?
    find('#cf0925_funded_person_attributes_user_attributes_work_phone_number + span.help-block')
    true
  rescue Capybara::ElementNotFound => e
    puts e.inspect
    false
  end

  def set_home_phone_number(phone_number)
    find('div.parent-test').fill_in('Home Phone', with: phone_number)
  end

  def set_work_phone_number(phone_number)
    find('div.parent-test').fill_in('Work Phone', with: phone_number)
  end

  def set_part_b_fiscal_year(fiscal_year)
    select fiscal_year, from: 'cf0925_part_b_fiscal_year'
  end

  def set_parent_postal_code(postal_code)
    find('div.parent-test').fill_in('Postal Code', with: postal_code)
  end

  def set_field(field, value)
    field_id = 'cf0925_' + field.to_s
    element = find('#' + field_id)
    # puts element.tag_name
    case element.tag_name
    when 'input'
      case element['type']
      when 'text', 'tel', 'date'
        # puts "fill_in #{field_id}, with: #{value}"
        fill_in field_id, with: value
      when 'radio'
        # puts "choose #{field_id}"
        choose field_id
      else
        puts "Not implemented: #{element['type']}"
      end
    when 'select'
      # puts "select #{field_id}, #{value}"
      select value, from: field_id
    else
      puts "Not implemented: #{element.tag_name}"
    end
  end
end
