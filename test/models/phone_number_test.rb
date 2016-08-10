require 'test_helper'
class PhoneNumberTest < ActiveSupport::TestCase
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that a PhoneNumber.new will create an instance of the object
  # => b) tests that the new PhoneNumber object instance is of the class PhoneNumber
  # => c) tests that a PhoneNumber instance is invalid if user is not set
  # => d) tests that a PhoneNumber instance is invalid if phone_number is invalid
  # => e) tests that a PhoneNumber instance is invalid if phone_extension is invalid
  # => f) tests that a PhoneNumber instance is invalid if phone_type is missing
  # => g) tests that a user instance is valid if phone_number is valid and phone_type is set
  # => h) tests that a user instance is valid if phone_number is valid and phone_type is set and extension is valid
  # => i) ensure a save is successful if valid? is true
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
    the_phone.phone_extension = nil
    the_phone.phone_type = test_phone_type
    assert_not the_phone.valid?, '01.c: the_phone should not be valid (No user)'

    # 01.d .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_invalid_phone_number
    the_phone.phone_extension = nil
    the_phone.phone_type = test_phone_type
    assert_not the_phone.valid?, '01.d: the_phone should not be valid (Invalid phone_number)'

    # 01.e .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = test_invalid_phone_extension
    the_phone.phone_type = test_phone_type
    assert_not the_phone.valid?, '01.e: the_phone should not be valid (Invalid phone_extension)'

    # 01.f .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = test_valid_phone_extension
    the_phone.phone_type = nil
    assert_not the_phone.valid?, '01.f: the_phone should not be valid (No phone_type)'

    # 01.g .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = nil
    the_phone.phone_type = test_phone_type
    assert the_phone.valid?, '01.g: the_phone should be valid (valid phone_number and phone_type)'

    # 01.h .....................................................................
    the_phone.user = test_user
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = test_valid_phone_extension
    the_phone.phone_type = test_phone_type
    assert the_phone.valid?, '01.h: the_phone should be valid (valid phone_number, phone_extension and phone_type)'

    # 01.i .....................................................................
    assert the_phone.save, '01.i: Save of an valid instance should succeed'

  end #-- end test --------------------------------------------------------

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a) tests full_number method produces (???) ???-???? x??? with a bad area code, phone_number and extension
  # => b) tests full_number method returns zero length string if no phone number or extension defined
  # => c) tests full_number method with a valid area code, phone_number and extension
  testName = '02 Check PhoneNumber formatting functions'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_valid_phone_number = '  613 297  7069 '
    test_full_phone_number = '(613) 297-7069 x1245'
    test_invalid_phone_number = '  6b2 657   0987'
    test_valid_phone_extension = '  1245 '
    test_invalid_phone_extension = 'x24'

    # 01.a .....................................................................
    the_phone = PhoneNumber.new
    the_phone.phone_number = test_invalid_phone_number
    the_phone.phone_extension = test_invalid_phone_extension
    expected = "(???) ???-???? x???"
    assert_equal expected, the_phone.full_number, '02.a: full_number does not return error formatted phone number'

    # 01.b .....................................................................
    the_phone = PhoneNumber.new
    the_phone.phone_number = nil
    expected = ""
    assert_equal expected, the_phone.full_number, '02.b: full_number does not return \'\' when not phone number and extension supplied'

    # 01.b .....................................................................
    the_phone = PhoneNumber.new
    the_phone.phone_number = test_valid_phone_number
    the_phone.phone_extension = test_valid_phone_extension
    expected = test_full_phone_number
    assert_equal expected, the_phone.full_number, '02.c: full_number does not return properly formatted phone number'

  end #-- end test --------------------------------------------------------

end






#    the_phone.valid?
#    puts ""
#    the_phone.errors.messages.each do |m|
#      puts "**Line: #{__LINE__}: An error: #{m} id: #{the_phone.id}"
#    end
#    puts "Line: #{__LINE__}: The phone extension: [#{the_phone.phone_extension}]  valid: [#{the_phone.valid?}] number: [#{the_phone.phone_number}]"
#
