require 'test_helper'
require 'helpers/my_profile_test_helpers.rb'
class MyProfileTest < MyProfileTestHelper::MyPage

  class TextBoxTest
    include Capybara::DSL
    def initialize(id,value)
      @id = id
      @value = value
    end

    def fill_in_field
        fill_in @id, with: @value
    end

    def check?
      first("##{@id}").value == @value
    end
  end

  class ValidTextBoxTest < TextBoxTest
    def initialize(id,value,error_message)
      super(id,value)
      @error_message = error_message
    end

    def check?
      ! chk_for_error_message(@id, @error_message) && super
    end
  end

  class InvalidTextBoxTest < TextBoxTest
    def initialize(id,value,error_message)
      super(id,value)
      @error_message = error_message
    end
    def check?
      chk_for_error_message(@id, @error_message) && super
    end

  end

  class WorkPhoneNumberTest < TextBoxTest
    def initialize (phone_number='6045556666')
      super('user_work_phone_number',phone_number)
      @error_message = '- must be 10 digit, area code/exchange must not start with 1 or 0'
    end
  end

  class InvalidWorkPhoneNumberTest < WorkPhoneNumberTest
    def initialize ()
      super('60455566')
    end
  end


  class PostalCodeTest < CapybaraTest
    include Capybara::DSL


    def initialize (postal_code='V2E 1V4')
      @postal_code = postal_code
      @id = 'user_postal_code'
      @error_message = ' - must be of the format ANA NAN'
    end

    def fill_in_field
        fill_in @id, with: @postal_code
    end

    attr_reader :postal_code

    def check?
      puts "#{__LINE__}: We are here!!! #{PostalCodeTest.ancestors}"
      # assert false, "This assertion worked, but failed"

      ! chk_for_error_message(@id, @error_message) && first("##{@id}").value == @postal_code

    end

    def chk_for_error_message(id, message)
      return false unless ( res = first("##{id} + span.help-block") )
      res.has_text?(message)
    end

  end
  class InvalidPostalCodeTest < PostalCodeTest
    def initialize()
      super('V2EEEE')
    end

    def check?
      chk_for_error_message(@id, @error_message) && first("##{@id}").value == @postal_code
    end
  end



  #-----------------------------------------------------------------------------
  #  Test 01 - Basic New User Sequence -
  # => a) Create new user (sign up)
  # => b) Log Out
  # => c) Log Back In
  # => d) Check that we wind up on my profile, with correct notifications
  # => e) Fill in and submit an address with bad postal code, check we return to profile with proper error
  testName = '01 Check User can be created and saved'
  test testName do
    test_email = 'a_guy@weenhanceit.com'
    test_password = 'very_secret'

    # a) Create new user (sign up)
    visit '/'
    assert_equal '/welcome/index', current_path, "01.a_i - Check Unregistered users wind up on welcome page"

    visit '/my_profile/edit'
    assert_equal '/welcome/index', current_path, "01.a_ii - Check Unregistered users wind up on welcome page"

    # There are many Sign Up links on the page, so do within
    within '.navbar' do
      click_link 'Sign Up'
    end
    assert_equal '/users/sign_up', current_path, "01.a_iii - Should be on sign_up page"

    fill_in 'Email', with: test_email
    fill_in 'Password', with: test_password
    fill_in 'Password confirmation', with: test_password
    assert_difference 'User.count',1, '01.a_iv - Number of Users did not increase by 1' do
      click_button 'Sign up'
    end

    # b) Log Out
    click_link 'Log out'
    assert_equal '/welcome/index', current_path, "01.b - Check Logged out users wind up on welcome page"

    # c) Log Back In
    within '.navbar' do
      click_link 'Log in'
    end
    assert_equal '/users/sign_in', current_path, "01.c - Should be on Log In Page"
    fill_in 'Email', with: test_email
    fill_in 'Password', with: test_password
    click_button 'Log in'


    # d) Check that we wind up on my profile, with correct notifications
    assert_equal '/my_profile/edit', current_path, "01.d.i - Brand New Users should be sent to My Profile"

    # New users should see the 'To begin taking.. '.  This is an integration test that
    # user.missing_key_info? is true - no profile information has been defined
    assert chk_for_not_enough_info_notification?, '01.d.ii - New Users should see notification of key info missing'

    # New users should also see the 'The forms and funding.. '.  This is an integration test that
    # user.bc_resident? is false - no province has been defined
    assert chk_for_not_bc_resident_notification?, '01.d.iii - New Users should see notification of not a resident of BC'

    #======================================================================================================
    # => e) Fill in and submit an address with bad postal code, check we return to profile with proper error
    puts "#{__LINE__}: (MyProfileTest) My Class: #{self.class} Assertions: #{self.assertions}"
#    MyProfileTest.ancestors.find {|c| puts " #{c} - #{c.class} assert: #{c.instance_methods(false).include? :assert} assertions: #{c.instance_methods(false).include? :assertions}"}
    puts "#{__LINE__}: ---------"
    msg = "Damn, an error!"
    # assert msg, msg
    # assert_not msg, msg

#    CapybaraTest.ancestors.find {|c| puts " #{c} - #{c.class} assert: #{c.instance_methods(false).include? :assert} assertions: #{c.instance_methods(false).include? :assertions}"}
    puts "#{__LINE__}: ---------"
    # a = MyPage.new
    be_silly
    # pip
    puts "Am I here: #{be_silly}"
    puts "#{__LINE__}: Address Valid Value: #{get_valid_value(:address)}"
    set_valid_value(:address,'123 Main St')
    puts "#{__LINE__}: Address Valid Value: #{get_valid_value(:address)}"
    puts "#{__LINE__}: My Class #{self.class}"
#    puts "#{__LINE__}:  Whence assert: #{m.source_location}"
am = self.method(:assert)
puts "#{__LINE__}: am.source_location:  #{am.source_location}"

am = self.method(:assertions)
puts "#{__LINE__}: am.source_location:  #{am.source_location}"
puts "#{__LINE__}: Assertions: #{self.assertions}"

the_mess = 'Phil'
    check_form(__LINE__, "01.e",the_mess)
puts "#{__LINE__}: Assertions: #{self.assertions} message back: #{the_mess}"

    postal_code_instance = InvalidPostalCodeTest.new
    good_postal_code_instance = PostalCodeTest.new
    invalid_work_phone_number_instance = InvalidWorkPhoneNumberTest.new

    assert_no_difference 'User.count' do
      fill_in 'user_name_first', with: get_a_param_hash(:invalid_bc_address)[:name_first]
      fill_in 'user_name_last', with: get_a_param_hash(:invalid_bc_address)[:name_last]
      fill_in 'user_address', with: get_a_param_hash(:invalid_bc_address)[:address_line_1]
      fill_in 'user_city', with: get_a_param_hash(:invalid_bc_address)[:city]
      select get_a_param_hash(:invalid_bc_address)[:province], from: 'user_province_code_id'
      postal_code_instance.fill_in_field
      invalid_work_phone_number_instance.fill_in_field
#      fill_in 'home_phone_number_phone_number', with: '5555555555'
#      fill_in 'work_phone_number_phone_number', with: '6666666666'
      click_link_or_button 'Update User'
    end

    assert_equal '/my_profile/edit', current_path, "01.e.i - Errors should cause redirect to My Profile"

    # No Funded Children, so should  still see the 'To begin taking.. '.  This is an integration test that
    # user.missing_key_info? is true
    assert chk_for_not_enough_info_notification?, '01.e.ii - Should see notification of key info missing as no funded children defined'

    # Since Province of BC defined, should NOT see the 'The forms and funding.. '.  This is an integration test that
    # user.bc_resident? is true
    assert_not chk_for_not_bc_resident_notification?, '01.e.iii - Should NOT see notification of not a resident of BC'

    # Is the postal code error message showing up after the
    expected_message = ' - must be of the format ANA NAN'
    assert chk_for_error_message('user_postal_code',expected_message),'01.e.iv - No error message for invalid postal code'

    assert good_postal_code_instance.check?, "#{__LINE__}: CHECK FAILED"


    assert postal_code_instance.check?, "#{__LINE__}: CHECK FAILED"
    assert invalid_work_phone_number_instance.check?, "CHECK FAIL"

  end


  test 'create a user and fill in the user profile (but not child)' do
    password = 'boson-detector'
    puts "Address: #{get_a_param_hash(:valid_address).to_s} Unknown: #{get_a_param_hash(:hashdef).to_s}"

    visit '/'
    assert_equal '/welcome/index', current_path
    # There are many Sign Up links on the page, so do within
    within '.navbar' do
      click_link 'Sign Up'
    end

    email = 'myprofiletest@weenhanceit.com'
    assert_equal '/users/sign_up', current_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    fill_in 'Password confirmation', with: password
    assert_difference 'User.count' do
      click_button 'Sign up'
    end

    # We pre-create empty records so this test will fail for a brand new user.
    # assert_equal 0, User.find_by(email: email).addresses.size

    ## Changed functionality so that new users are redirected to the my_profile_edit path
    ##  Therefore the following tests are removed ---
    ##assert_equal '/', current_path
    ##within 'nav' do
    ##  click_link 'My Profile'
    ##end
    ##assert_equal '/my_profile/index', current_path
    ##click_link 'edit'
    ##-- end removed tests

    assert_equal '/my_profile/edit', current_path
    address_hash = {
      address_line_1: '1234567 Main St',
      city: 'Kamloops',
      province_code_id: (province = ProvinceCode.find_by(province_code: 'BC')).id
    }

    user_hash = {
      name_first: 'Furst',
      name_last: 'Laast'
    }

    # assert_difference 'PhoneNumber.count', 2 do
    # assert_difference 'Address.count' do
    assert_no_difference 'User.count' do
      fill_in 'user_name_first', with: user_hash[:name_first]
      fill_in 'user_name_last', with: user_hash[:name_last]
      fill_in 'user_address', with: address_hash[:address_line_1]
      fill_in 'user_city', with: address_hash[:city]
      select province.province_name, from: 'user_province_code_id'
      fill_in 'user_home_phone_number', with: '5555555555'
      fill_in 'user_work_phone_number', with: '6666666666'
      click_link_or_button 'Update User'
    end
    # end
    # end

    assert_equal '/my_profile/edit', current_path
    user = User.find_by(name_last: user_hash[:name_last])
    assert_equal user_hash[:name_first], user.name_first
    assert_equal user_hash[:name_last], user.name_last
    assert_equal address_hash[:address_line_1], user.my_address.address_line_1
    assert_equal address_hash[:city], user.my_address.city
    assert_equal address_hash[:province_code_id], user.my_address.province_code_id
    assert_equal '(555) 555-5555', user.my_home_phone.full_number
    assert_equal '(666) 666-6666', user.my_work_phone.full_number
  end

  private

  # This method defines all of the parameter hashes uesed in the tests.  They are
  # defined here to make the code a bit more readable
  def get_a_param_hash(hashdef)
    case hashdef
    when :valid_bc_address
      {
        address_line_1: '1234567 Main St',
        city: 'Kamloops',
        province: (ProvinceCode.find_by(province_code: 'BC')).province_name,
        postal_code: 'V3A 4S7'
        }
    when :invalid_bc_address
      {
        address_line_1: '1234567 Main St',
        city: 'Kamloops',
        province: (ProvinceCode.find_by(province_code: 'BC')).province_name,
        postal_code: 'V3Ax4S7'
      }
    else
      {}
    end

  end
  def chk_for_not_enough_info_notification?
    test_content = 'To begin taking advantage of the functionality of this site you must enter the province of your address as well as at least one funded child'
    has_text? test_content
  end

  def chk_for_not_bc_resident_notification?
    test_content = 'The forms and funding found in this area are only availble to residents of British Columbia.'
    has_text? test_content
  end



  def chk_for_error_message(id, message)
    return false unless ( res = first("##{id} + span.help-block") )
    res.has_text?(message)
    #
    #
    # puts "WE ARE HERE!!!"
    # # all('.form-group.has-error').each do |x|
    # #   puts " #{__LINE__}"
    # #
    # #   # if x.has_text?  message
    # #   #   puts " !!! FOUDN ONE #{x.text}"
    # #   # end
    # #
    # #   # x.all('.has-error').each do |y|
    # #   #   puts "    #{__LINE__}"
    # #   #   # if y.has_text? 'user_postal_code'
    # #   #   #   puts "FOUDN ONE #{x.to_s}"
    # #   #   # else
    # #   #   #   puts 'Did not find shinola'
    # #   #   # end
    # #   # end
    # # end
  end
end
