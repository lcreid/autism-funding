require 'test_helper'
class PhoneNumberTest < ActiveSupport::TestCase
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that a PhoneNumber.new will create an instance of the object
  # => b) tests that the new PhoneNumber object instance is of the class PhoneNumber
  # => c) tests that a PhoneNumber instance is invalid if user is not set
  # => d) tests that a PhoneNumber instance is invalid if phone_number is not set
  # => e) tests that a PhoneNumber instance is invalid if phone_number is invalid
  # => f) tests that a PhoneNumber instance is invalid if phone_extension is invalid
  # => g) tests that a PhoneNumber instance is invalid if phone_type is missing
  # => h) tests that a user instance is valid if phone_number is valid and phone_type is set
  # => i) tests that a user instance is valid if phone_number is valid and phone_type is set and extension is valid
  # => j) ensure a save is successful if valid? is true
  testName = '01 Check PhoneNumber insance can be created and saved'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_user = users(:basic)
    test_valid_phone_number = '  613 297  7069 '
    test_clean_phone_number = '6132977069'
    test_invalid_phone_number = '  6b2 657   0987'
    test_valid_phone_extension = '  1245 '
    test_invalid_phone_extension = 'x24'
    test_phone_type = '  work '

    # 01.a .....................................................................
    the_phone = PhoneNumber.new
    assert_not_nil the_phone, '01.a: Instance of PhoneNumber Should not be nil'

    # 01.b .....................................................................
    assert_instance_of PhoneNumber, the_phone, '01.b: PhoneNmber instance should be of Class PhoneNumber'

    # 01.c .....................................................................
    the_phone.user = nil
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = nil
    the_phone.phone_type = test_phone_type
    assert_not the_phone.valid?, '01.c: the_phone should not be valid (No user)'

    # 01.d .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = nil
    the_phone.phone_extension = nil
    the_phone.phone_type = test_phone_type
    assert_not the_phone.valid?, '01.d: the_phone should not be valid (No phone_number)'

    # 01.e .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_invalid_phone_number
    the_phone.phone_extension = nil
    the_phone.phone_type = test_phone_type
    assert_not the_phone.valid?, '01.e: the_phone should not be valid (Invalid phone_number)'

    # => f) tests that a PhoneNumber instance is invalid if phone_extension is invalid
    # => g) tests that a PhoneNumber instance is invalid if phone_type is missing
    # => h) tests that a user instance is valid if phone_number is valid and phone_type is set
    # => i) tests that a user instance is valid if phone_number is valid and phone_type is set and extension is valid
    # => j) ensure a save is successful if valid? is true

    # 01.f .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = test_invalid_phone_extension
    the_phone.phone_type = test_phone_type

    the_phone.errors.messages.each do |m|
      puts "**An error: #{m} id: #{the_phone.id}"
    end
    puts "The phone extension: [#{the_phone.phone_extension}]  valid: [#{the_phone.valid?}] number: [#{the_phone.phone_number}]"

    assert_not the_phone.valid?, '01.f: the_phone should not be valid (Invalid phone_extension)'

    # 01.g .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = test_valid_phone_extension
    the_phone.phone_type = test_phone_type
    assert_not the_phone.valid?, '01.g: the_phone should not be valid (No phone_type)'

    the_phone.errors.messages.each do |m|
      puts "An error: #{m} id: #{the_phone.id}"
    end

    # 01.d .....................................................................
    #  the_phone.user = valid_user
    #    the_phone.postal_code = valid_postal_code
    #  the_phone.province_code = nil
    assert_not the_phone.valid?, '01.d: the_phone should not be valid (No province_code)'
    assert false
    # 01.e .....................................................................
    the_phone.user = valid_user
    the_phone.postal_code = invalid_postal_code
    the_phone.province_code = valid_province_code
    assert_not the_phone.valid?, '01.e: the_phone should not be valid (Invalid postal code)'

    # 01.f .....................................................................
    the_phone.user = valid_user
    the_phone.postal_code = valid_postal_code
    the_phone.province_code = valid_province_code
    assert the_phone.valid?, '01.f: the_phone should be valid ( user, valid postal code and province code present)'

    # 01.g .....................................................................
    assert the_phone.save, 'Save of an valid instance should succeed'
  end #-- end test --------------------------------------------------------
end
