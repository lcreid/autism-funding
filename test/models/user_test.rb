require 'test_helper'

class UserTest < ActiveSupport::TestCase
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that a User.new will create an object
  # => b) tests that the new User object is of the class User
  # => c) tests that a user instance is invalid if email and password not set
  # => d) tests that a user instance is invalid if email set and password not set
  # => e) tests that a user instance is valid if email set and password set
  # => f) ensure a save is successful if valid? is true
  testName = "01 Check User can be created and saved"
  #puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_email = "user@someco.com"
    test_password = "secret"
    # 01.a .....................................................................
    the_user = User.new
    assert_not_nil the_user, "Instance of User Should not be nil"

    # 01.b .....................................................................
    assert_instance_of User, the_user, "Instance Should be of Class User"

    # 01.c .....................................................................
    the_user.email = nil
    the_user.password = nil
    assert_not the_user.valid?, "User instance should not be valid when email and password not set"

    # 01.d .....................................................................
    the_user.email = test_email
    the_user.password = nil
    assert_not the_user.valid?, "User instance should not be valid when only email set"

    # 01.e .....................................................................
    the_user.email = nil
    the_user.password = test_password
    assert_not the_user.valid?, "User instance should not be valid when only password set"

    # 01.f .....................................................................
    the_user.email = test_email
    the_user.password = test_password
    assert the_user.valid?, "User instance should be valid when email and password set"

    # 01.g .....................................................................
    assert the_user.save, "Save of an valid instance should succeed"


  end     ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a) tests that users(:basic) returns a valid user instance of class User
  # => b) tests that the instance is of the class User
  # => c) tests that users(:basic) instance is valid
  # => d) tests that my_name returns email when no name information is present
  # => e-k) tests that my_name only expected formatted name
  # => l) ensure valid? is true with names set
  # => m) ensure a save is successful if valid? is true
  testName = "02 Check User my_name method"
  #puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_first = "first"
    test_middle = "middle"
    test_last = "last"

    # 02.a .....................................................................
    the_user = users(:basic)
    assert_not_nil the_user, "02.a: users(:basic) Should not be nil"

    # 02.b .....................................................................
    assert_instance_of User, the_user, "02.b: users(:basic) Should be of Class User"

    # 02.c .....................................................................
    assert the_user.valid?, "02.c: users(:basic) should be valid"

    # 02.d .....................................................................
    expected = "#{the_user.email}"
    assert_equal expected, the_user.my_name, "02.d: my_name should return email, when no name present"

    # 02.d .....................................................................
    expected = "#{the_user.email}"
    assert_equal expected, the_user.my_name, "02.d: my_name should return email, when no name present"

    # 02.e .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = nil
    the_user.name_last = nil
    expected = "#{test_first}"
    assert_equal expected, the_user.my_name, "02.e: my_name did not return expected name"

    # 02.f .....................................................................
    the_user.name_first = nil
    the_user.name_middle = test_middle
    the_user.name_last = nil
    expected = "#{test_middle}"
    assert_equal expected, the_user.my_name, "02.f: my_name did not return expected name"

    # 02.g .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = test_middle
    the_user.name_last = nil
    expected = "#{test_first} #{test_middle}"
    assert_equal expected, the_user.my_name, "02.g: my_name did not return expected name"

    # 02.h .....................................................................
    the_user.name_first = nil
    the_user.name_middle = nil
    the_user.name_last = test_last
    expected = "#{test_last}"
    assert_equal expected, the_user.my_name, "02.h: my_name did not return expected name"

    # 02.i .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = nil
    the_user.name_last = test_last
    expected = "#{test_first} #{test_last}"
    assert_equal expected, the_user.my_name, "02.i: my_name did not return expected name"

    # 02.j .....................................................................
    the_user.name_first = nil
    the_user.name_middle = test_middle
    the_user.name_last = test_last
    expected = "#{test_middle} #{test_last}"
    assert_equal expected, the_user.my_name, "02.j: my_name did not return expected name"

    # 02.k .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = test_middle
    the_user.name_last = test_last
    expected = "#{test_first} #{test_middle} #{test_last}"
    assert_equal expected, the_user.my_name, "02.k: my_name did not return expected name"

    # 02.h .....................................................................
    assert the_user.valid?, "02.h: User instance should be valid when name added"

    # 02.i .....................................................................
    assert the_user.save, "02.i: Save of an valid instance should succeed"
  end     ## -- end test --

#-----------------------------------------------------------------------------
#  Test 03
# => a) tests that users(:has_no_fp) has no related funded_people
# => b) tests that users(:has_one_fp) has 1 related funded_people
# => c) tests that users(:has_two_fp) has 2 related funded_people
testName = "03 Check Relationship with FundedPerson"
#puts "-- Test: #{testName} -----------------------------------"
test testName do
  # 03.a .....................................................................
  the_user = users(:has_no_fp)
  assert_equal 0,the_user.funded_people.size, "03.a: Instance [#{the_user.my_name}] should have no funded_people"

  # 03.b .....................................................................
  the_user = users(:has_one_fp)
  assert_equal 1,the_user.funded_people.size, "03.b: Instance [#{the_user.my_name}] should have 1 funded_people"

  # 03.c .....................................................................
  the_user = users(:has_two_fp)
  assert_equal 2,the_user.funded_people.size, "03.b: Instance [#{the_user.my_name}] should have 2 funded_people"

end     ## -- end test --

#-----------------------------------------------------------------------------
#  Test 04
# => a) tests that users(:has_no_phone) has no related phone_numbers
# => b) tests that users(:has_one_phone) has 1 related phone_numbers
# => c) tests that users(:has_two_phone) has 2 related phone_numbers
testName = "04 Check Relationship with PhoneNumber"
#puts "-- Test: #{testName} -----------------------------------"
test testName do
  # 04.a .....................................................................
  the_user = users(:has_no_phone)
  assert_equal 0,the_user.phone_numbers.size, "04.a: Instance [#{the_user.my_name}] should have no phone_numbers"

  # 04.b .....................................................................
  the_user = users(:has_one_phone)
  assert_equal 1,the_user.phone_numbers.size, "04.b: Instance [#{the_user.my_name}] should have 1 phone_numbers"

  # 04.c .....................................................................
  the_user = users(:has_two_phone)
  assert_equal 2,the_user.phone_numbers.size, "04.c: Instance [#{the_user.my_name}] should have 2 phone_numbers"

end     ## -- end test --

#-----------------------------------------------------------------------------
#  Test 05
# => a) tests that new user has no related addresses
# => b) tests that new user get_address returns a nil
# => c) tests that users(:has_no_address) has no related addresses
# => d) tests that users(:has_no_address).my_address returns an instance of class Address
# => e) tests that users(:has_no_address).my_address returns an instance with a correct user_id
# => f) tests that users(:has_no_address).my_address returns an Address instance that is a blank address
# => g) tests that users(:has_no_address) now has one related address
# => h) tests that users(:has_one_address) has 1 related address
# => i) tests that users(:has_one_address).my_address returns an instance of class Address
# => j) tests that users(:has_no_address).my_address returns an instance with a correct user_id
# => k) tests that users(:has_one_address).my_address returns expected Address data
testName = "05 Check Relationship with Address and my_address"
#puts "-- Test: #{testName} -----------------------------------"
test testName do
  # 05.a .....................................................................
  the_user = User.new
  assert_equal 0,the_user.addresses.size, "05.a: Instance [#{the_user.my_name}] should have no addresses"

  # 05.b .....................................................................
  assert_nil the_user.my_address, "05.b: Instance [#{the_user.my_name}.my_address] should return nil as no id has been created"

  # 05.c .....................................................................
  the_user = users(:has_no_address)
  assert_equal 0,the_user.addresses.size, "05.c: Instance [#{the_user.my_name}] should have 0 addresses"

  # 05.d .....................................................................
  the_address = the_user.my_address
  assert_instance_of Address, the_address, "05.d:  [#{the_user.my_name}.my_address] should return instance of class Address"

  # 05.e .....................................................................
  assert_equal the_user.id,the_address.user_id, "05.e: Instance [#{the_user.my_name}],my_address has an incorrect user_id"

  # 05.f .....................................................................
  expected = ""
  assert_equal expected, the_address.get_full_address(blank_address: ""), "05.f: Instance [#{the_user.my_name}],my_address is not a blank address"

  # 05.g .....................................................................
  assert_equal 1,the_user.addresses.size, "05.g: Instance [#{the_user.my_name}] should now have 1 addresses"

  # 05.h .....................................................................
  the_user = users(:has_one_address)
  assert_equal 1,the_user.addresses.size, "05.h: Instance [#{the_user.my_name}] should have 1 address"

  # 05.i .....................................................................
  the_address = the_user.my_address
  assert_instance_of Address, the_address, "05.i:  [#{the_user.my_name}.my_address] should return instance of class Address"

  # 05.j .....................................................................
  assert_equal the_user.id,the_address.user_id, "05.j: Instance [#{the_user.my_name}.my_address has an incorrect user_id"

  # 05.k .....................................................................
  expected = Address.find_by( user_id: the_user.id).get_full_address
  assert_equal expected, the_address.get_full_address, "05.k: Instance [#{the_user.my_name}].my_address is not correct"
end     ## -- end test --

#-----------------------------------------------------------------------------
#  Test 06
# => a) tests that new user has no related phone_numbers
# => b) tests that new user my_home_phone returns a nil
# => c) tests that users(:has_no_phone) has no related addresses
# => d) tests that users(::has_no_phone).my_home_phone returns an instance of class PhoneNumber
# => e) tests that users(::has_no_phone).my_home_phone returns an instance with a correct user_id
# => f) tests that users(::has_no_phone).my_home_phone returns a PhoneNumber instance that has a nil phone_number
# => g) tests that users(::has_no_phone).my_home_phone returns a PhoneNumber instance that has the correct phone_type
# => h) tests that users(:has_no_address) now has one related phone number
# => i) tests that users(:has_two_phone) has 2 related phone numbers
# => j) tests that users(:has_two_phone).my_home_phone returns an instance of class PhoneNumber
# => k) tests that users(:has_two_phone).my_home_phone returns an instance with a correct user_id
# => l) tests that users(:has_two_phone).my_home_phone returns expected Phone data
# => m) tests that users(:has_two_phone).my_home_phone returns expected phone type
testName = "06 Check my_home_phone"
#puts "-- Test: #{testName} -----------------------------------"
test testName do
  test_phone_type = "Home"
  # 06.a .....................................................................
  the_user = User.new
  assert_equal 0,the_user.phone_numbers.size, "06.a: Instance [#{the_user.my_name}] should have no phone_numbers"

  # 06.b .....................................................................
  assert_nil the_user.my_home_phone, "06.b: Instance [#{the_user.my_name}.my_home_phone] should return nil as no id has been created"

  # 06.c .....................................................................
  the_user = users(:has_no_phone)
  assert_equal 0,the_user.phone_numbers.size, "06.c: Instance [#{the_user.my_name}] should have 0 phone_numbers"

  # 06.d .....................................................................
  the_phone_number = the_user.my_home_phone
  assert_instance_of PhoneNumber, the_phone_number, "06.d:  [#{the_user.my_name}.my_home_phone] should return instance of class APhoneNumber"

  # 06.e .....................................................................
  assert_equal the_user.id,the_phone_number.user_id, "06.e: Instance [#{the_user.my_name}],my_home_phone has an incorrect user_id"

  # 06.f .....................................................................
  assert_nil the_phone_number.phone_number, "06.f: Instance [#{the_user.my_name}],my_home_phone is not a blank phone number"

  # 06.g .....................................................................
  expected = test_phone_type
  assert_equal expected, the_phone_number.phone_type, "06.g: Instance [#{the_user.my_name}],my_home_phone should have the correct type"

  # 06.h .....................................................................
  assert_equal 1,the_user.phone_numbers.size, "06.h: Instance [#{the_user.my_name}] should now have 1 phone number"

  # 06.i .....................................................................
  the_user = users(:has_two_phone)
  assert_equal 2,the_user.phone_numbers.size, "06.i: Instance [#{the_user.my_name}] should have 2 phone numbers"

  # 06.j .....................................................................
  the_phone_number = the_user.my_home_phone
  assert_instance_of PhoneNumber, the_phone_number, "06.j:  [#{the_user.my_name}.my_home_number] should return instance of class PhoneNumber"

  # 06.k .....................................................................
  assert_equal the_user.id,the_phone_number.user_id, "06.k: Instance [#{the_user.my_name}.my_home_phone has an incorrect user_id"

  # 06.l .....................................................................
  expected = PhoneNumber.find_by( user_id: the_user.id, phone_type: test_phone_type).full_number
  assert_equal expected, the_phone_number.full_number, "06.l: Instance [#{the_user.my_name}].my_home_number phone_number is not correct"

  # 06.m .....................................................................
  expected = test_phone_type
  assert_equal expected, the_phone_number.phone_type, "06.m: Instance [#{the_user.my_name}],my_home_phone should have the correct type"

end     ## -- end test --

#-----------------------------------------------------------------------------
#  Test 07
# => a) tests that new user has no related phone_numbers
# => b) tests that new user my_work_phone returns a nil
# => c) tests that users(:has_no_phone) has no related addresses
# => d) tests that users(::has_no_phone).my_work_phone returns an instance of class PhoneNumber
# => e) tests that users(::has_no_phone).my_work_phone returns an instance with a correct user_id
# => f) tests that users(::has_no_phone).my_work_phone returns a PhoneNumber instance that has a nil phone_number
# => g) tests that users(::has_no_phone).my_work_phone returns a PhoneNumber instance that has the correct phone_type
# => h) tests that users(:has_no_address) now has one related phone number
# => i) tests that users(:has_two_phone) has 2 related phone numbers
# => j) tests that users(:has_two_phone).my_work_phone returns an instance of class PhoneNumber
# => k) tests that users(:has_two_phone).my_work_phone returns an instance with a correct user_id
# => l) tests that users(:has_two_phone).my_work_phone returns expected Phone data
# => m) tests that users(:has_two_phone).my_work_phone returns expected phone type
testName = "07 Check my_work_phone"
#puts "-- Test: #{testName} -----------------------------------"
test testName do
  test_phone_type = "Work"
  # 07.a .....................................................................
  the_user = User.new
  assert_equal 0,the_user.phone_numbers.size, "07.a: Instance [#{the_user.my_name}] should have no phone_numbers"

  # 07.b .....................................................................
  assert_nil the_user.my_work_phone, "07.b: Instance [#{the_user.my_name}.my_work_phone] should return nil as no id has been created"

  # 07.c .....................................................................
  the_user = users(:has_no_phone)
  assert_equal 0,the_user.phone_numbers.size, "07.c: Instance [#{the_user.my_name}] should have 0 phone_numbers"

  # 07.d .....................................................................
  the_phone_number = the_user.my_work_phone
  assert_instance_of PhoneNumber, the_phone_number, "07.d:  [#{the_user.my_name}.my_work_phone] should return instance of class APhoneNumber"

  # 07.e .....................................................................
  assert_equal the_user.id,the_phone_number.user_id, "07.e: Instance [#{the_user.my_name}],my_work_phone has an incorrect user_id"

  # 07.f .....................................................................
  assert_nil the_phone_number.phone_number, "07.f: Instance [#{the_user.my_name}],my_work_phone is not a blank phone number"

  # 07.g .....................................................................
  expected = test_phone_type
  assert_equal expected, the_phone_number.phone_type, "07.g: Instance [#{the_user.my_name}],my_work_phone should have the correct type"

  # 07.h .....................................................................
  assert_equal 1,the_user.phone_numbers.size, "07.h: Instance [#{the_user.my_name}] should now have 1 phone number"

  # 07.i .....................................................................
  the_user = users(:has_two_phone)
  assert_equal 2,the_user.phone_numbers.size, "07.i: Instance [#{the_user.my_name}] should have 2 phone numbers"

  # 07.j .....................................................................
  the_phone_number = the_user.my_work_phone
  assert_instance_of PhoneNumber, the_phone_number, "07.j:  [#{the_user.my_name}.my_home_number] should return instance of class PhoneNumber"

  # 07.k .....................................................................
  assert_equal the_user.id,the_phone_number.user_id, "07.k: Instance [#{the_user.my_name}.my_work_phone has an incorrect user_id"

  # 07.l .....................................................................
  expected = PhoneNumber.find_by( user_id: the_user.id, phone_type: test_phone_type).full_number
  assert_equal expected, the_phone_number.full_number, "07.l: Instance [#{the_user.my_name}].my_home_number phone_number is not correct"

  # 07.m .....................................................................
  expected = test_phone_type
  assert_equal expected, the_phone_number.phone_type, "07.m: Instance [#{the_user.my_name}],my_work_phone should have the correct type"

end     ## -- end test --


end
