require 'test_helper'

class UserTest < ActiveSupport::TestCase
    include TestSessionHelpers
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that a User.new will create an object
  # => b) tests that the new User object is of the class User
  # => c) tests that a user instance is invalid if email and password not set
  # => d) tests that a user instance is invalid if email set and password not set
  # => e) tests that a user instance is valid if email set and password set
  # => f) ensure a save is successful if valid? is true
  testName = '01 Check User can be created and saved'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_email = 'user@someco.com'
    test_password = 'secret'
    # 01.a .....................................................................
    the_user = User.new
    assert_not_nil the_user, 'Instance of User Should not be nil'

    # 01.b .....................................................................
    assert_instance_of User, the_user, 'Instance Should be of Class User'

    # 01.c .....................................................................
    the_user.email = nil
    the_user.password = nil
    assert_not the_user.valid?, 'User instance should not be valid when email and password not set'

    # 01.d .....................................................................
    the_user.email = test_email
    the_user.password = nil
    assert_not the_user.valid?, 'User instance should not be valid when only email set'

    # 01.e .....................................................................
    the_user.email = nil
    the_user.password = test_password
    assert_not the_user.valid?, 'User instance should not be valid when only password set'

    # 01.f .....................................................................
    the_user.email = test_email
    the_user.password = test_password
    assert the_user.valid?, 'User instance should be valid when email and password set'

    # 01.g .....................................................................
    assert the_user.save, 'Save of an valid instance should succeed'
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a) tests that users(:basic) returns a valid user instance of class User
  # => b) tests that the instance is of the class User
  # => c) tests that users(:basic) instance is valid
  # => d) tests that my_name returns email when no name information is present
  # => e-k) tests that my_name only expected formatted name
  # => l) ensure valid? is true with names set
  # => m) ensure a save is successful if valid? is true
  testName = '02 Check User my_name method'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_first = 'first'
    test_middle = 'middle'
    test_last = 'last'

    # 02.a .....................................................................
    the_user = users(:basic)
    assert_not_nil the_user, '02.a: users(:basic) Should not be nil'

    # 02.b .....................................................................
    assert_instance_of User, the_user, '02.b: users(:basic) Should be of Class User'

    # 02.c .....................................................................
    assert the_user.valid?, '02.c: users(:basic) should be valid'

    # 02.d .....................................................................
    expected = the_user.email.to_s
    assert_equal expected, the_user.my_name, '02.d: my_name should return email, when no name present'

    # 02.d .....................................................................
    expected = the_user.email.to_s
    assert_equal expected, the_user.my_name, '02.d: my_name should return email, when no name present'

    # 02.e .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = nil
    the_user.name_last = nil
    expected = test_first.to_s
    assert_equal expected, the_user.my_name, '02.e: my_name did not return expected name'

    # 02.f .....................................................................
    the_user.name_first = nil
    the_user.name_middle = test_middle
    the_user.name_last = nil
    expected = test_middle.to_s
    assert_equal expected, the_user.my_name, '02.f: my_name did not return expected name'

    # 02.g .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = test_middle
    the_user.name_last = nil
    expected = "#{test_first} #{test_middle}"
    assert_equal expected, the_user.my_name, '02.g: my_name did not return expected name'

    # 02.h .....................................................................
    the_user.name_first = nil
    the_user.name_middle = nil
    the_user.name_last = test_last
    expected = test_last.to_s
    assert_equal expected, the_user.my_name, '02.h: my_name did not return expected name'

    # 02.i .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = nil
    the_user.name_last = test_last
    expected = "#{test_first} #{test_last}"
    assert_equal expected, the_user.my_name, '02.i: my_name did not return expected name'

    # 02.j .....................................................................
    the_user.name_first = nil
    the_user.name_middle = test_middle
    the_user.name_last = test_last
    expected = "#{test_middle} #{test_last}"
    assert_equal expected, the_user.my_name, '02.j: my_name did not return expected name'

    # 02.k .....................................................................
    the_user.name_first = test_first
    the_user.name_middle = test_middle
    the_user.name_last = test_last
    expected = "#{test_first} #{test_middle} #{test_last}"
    assert_equal expected, the_user.my_name, '02.k: my_name did not return expected name'

    # 02.l .....................................................................
    assert the_user.valid?, '02.l: User instance should be valid when name added'

    # 02.m .....................................................................
    assert the_user.save, '02.m: Save of an valid instance should succeed'
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 03
  # => a) tests that users(:has_no_fp) has no related funded_people
  # => b) tests that users(:has_one_fp) has 1 related funded_people
  # => c) tests that users(:has_two_fp) has 2 related funded_people
  testName = '03 Check Relationship with FundedPerson'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # 03.a .....................................................................
    the_user = users(:has_no_fp)
    assert_equal 0, the_user.funded_people.size, "03.a: Instance [#{the_user.my_name}] should have no funded_people"

    # 03.b .....................................................................
    the_user = users(:has_one_fp)
    assert_equal 1, the_user.funded_people.size, "03.b: Instance [#{the_user.my_name}] should have 1 funded_people"

    # 03.c .....................................................................
    the_user = users(:has_two_fp)
    assert_equal 2, the_user.funded_people.size, "03.b: Instance [#{the_user.my_name}] should have 2 funded_people"
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 04
  # => a) tests that users(:has_no_phone) has no related phone_numbers
  # => b) tests that users(:has_one_phone) has 1 related phone_numbers
  # => c) tests that users(:has_two_phone) has 2 related phone_numbers
  testName = '04 Check Relationship with PhoneNumber'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # 04.a .....................................................................
    the_user = users(:has_no_phone)
    assert_equal 0, the_user.phone_numbers.size, "04.a: Instance [#{the_user.my_name}] should have no phone_numbers"

    # 04.b .....................................................................
    the_user = users(:has_one_phone)
    assert_equal 1, the_user.phone_numbers.size, "04.b: Instance [#{the_user.my_name}] should have 1 phone_numbers"

    # 04.c .....................................................................
    the_user = users(:has_two_phone)
    assert_equal 2, the_user.phone_numbers.size, "04.c: Instance [#{the_user.my_name}] should have 2 phone_numbers"
  end ## -- end test --

  # #-----------------------------------------------------------------------------
  # #  Test 05
  # # => a) tests that new user has no related addresses
  # # => b) tests that new user get_address creates an address
  # # => c) tests that users(:has_no_address) has no related addresses
  # # => d) tests that users(:has_no_address).my_address returns an instance of class Address
  # # => e) tests that users(:has_no_address).my_address returns an instance with a correct user_id
  # # => f) tests that users(:has_no_address).my_address returns an Address instance that is a blank address
  # # => g) tests that users(:has_no_address) now has one related address
  # # => h) tests that users(:has_one_address) has 1 related address
  # # => i) tests that users(:has_one_address).my_address returns an instance of class Address
  # # => j) tests that users(:has_no_address).my_address returns an instance with a correct user_id
  # # => k) tests that users(:has_one_address).my_address returns expected Address data
  # testName = '05 Check Relationship with Address and my_address'
  # # puts "-- Test: #{testName} -----------------------------------"
  # test testName do
  #   # 05.a .....................................................................
  #   the_user = User.new
  #   assert_equal 0, the_user.addresses.size, "05.a: Instance [#{the_user.my_name}] should have no addresses"
  #
  #   # 05.b .....................................................................
  #   the_user.my_address
  #   assert_equal 1, the_user.addresses.size, "05.b: Instance [#{the_user.my_name}] should have 1 address"
  #
  #
  #
  #   # 05.c .....................................................................
  #   the_user = users(:has_no_address)
  #   assert_equal 0, the_user.addresses.size, "05.c: Instance [#{the_user.my_name}] should have 0 addresses"
  #
  #   # 05.d .....................................................................
  #   the_address = the_user.my_address
  #   assert_instance_of Address, the_address, "05.d:  [#{the_user.my_name}.my_address] should return instance of class Address"
  #
  #   # 05.e .....................................................................
  #   assert_equal the_user.id, the_address.user_id, "05.e: Instance [#{the_user.my_name}],my_address has an incorrect user_id"
  #
  #   # 05.f .....................................................................
  #   expected = ''
  #   assert_equal expected, the_address.get_full_address(blank_address: ''), "05.f: Instance [#{the_user.my_name}],my_address is not a blank address"
  #
  #   # 05.g .....................................................................
  #   assert_equal 1, the_user.addresses.size, "05.g: Instance [#{the_user.my_name}] should now have 1 addresses"
  #
  #   # 05.h .....................................................................
  #   the_user = users(:has_one_address)
  #   assert_equal 1, the_user.addresses.size, "05.h: Instance [#{the_user.my_name}] should have 1 address"
  #
  #   # 05.i .....................................................................
  #   the_address = the_user.my_address
  #   assert_instance_of Address, the_address, "05.i:  [#{the_user.my_name}.my_address] should return instance of class Address"
  #
  #   # 05.j .....................................................................
  #   assert_equal the_user.id, the_address.user_id, "05.j: Instance [#{the_user.my_name}.my_address has an incorrect user_id"
  #
  #   # 05.k .....................................................................
  #   expected = Address.find_by(user_id: the_user.id).get_full_address
  #   assert_equal expected, the_address.get_full_address, "05.k: Instance [#{the_user.my_name}].my_address is not correct"
  # end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 06
  # => a) tests that new user home_phone_number is nil
  # => b) tests that new user work_phone_number is nil
  # => c) tests that new user work_phone_extension is nil
  # => d) tests that can set home_phone_number
  # => e) tests that can set work_phone_number
  # => f) tests that can set work_phone_extension
  testName = '06 Check Phone Numbers'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_phone_type = 'Home'
    # 06.a .....................................................................
    the_user = User.new
    assert_nil the_user.home_phone_number, "06.a: New User should have a nil home_phone_number"

    # 06.b .....................................................................
    assert_nil the_user.work_phone_number, "06.b: New User should have a nil work_phone_number"

    # 06.c .....................................................................
    assert_nil the_user.work_phone_extension, "06.c: New User should have a nil work_phone_extension"

    # 06.d .....................................................................
    test_number = '6045678234'
    the_user.home_phone_number = test_number
    the_user.work_phone_number = nil
    the_user.work_phone_extension = nil
    assert_equal test_number, the_user.home_phone_number, "06.d: could not set home_phone_number"

    # 06.e .....................................................................
    test_number = '6045678004'
    the_user.work_phone_number = test_number
    the_user.home_phone_number = nil
    the_user.work_phone_extension = nil
    assert_equal test_number, the_user.work_phone_number, "06.e: could not set work_phone_number"

    # 06.f .....................................................................
    test_ext = '60'
    the_user.work_phone_extension = test_ext
    the_user.home_phone_number = nil
    the_user.work_phone_number = nil
    assert_equal test_ext, the_user.work_phone_extension, "06.f: could not set work_phone_extension"
  end ## -- end test --

  #-----------------------------------------------------------------------------
  #  Test 07
  # => a) tests that new user has no related phone_numbers
  # => b) tests that new user has one phone number after my_work_phone
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
  testName = '07 Check my_work_phone'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_phone_type = 'Work'
    # 07.a .....................................................................
    the_user = User.new
    assert_equal 0, the_user.phone_numbers.size, "07.a: Instance [#{the_user.my_name}] should have no phone_numbers"

    # 07.b .....................................................................
    the_user.my_work_phone
    assert_equal 1, the_user.phone_numbers.size, "07.b: Instance [#{the_user.my_name}] Should have 1 phone number after my_work_phone"

    # 07.c .....................................................................
    the_user = users(:has_no_phone)
    assert_equal 0, the_user.phone_numbers.size, "07.c: Instance [#{the_user.my_name}] should have 0 phone_numbers"

    # 07.d .....................................................................
    the_phone_number = the_user.my_work_phone
    assert_instance_of PhoneNumber, the_phone_number, "07.d:  [#{the_user.my_name}.my_work_phone] should return instance of class APhoneNumber"

    # 07.e .....................................................................
    assert_equal the_user.id, the_phone_number.user_id, "07.e: Instance [#{the_user.my_name}],my_work_phone has an incorrect user_id"

    # 07.f .....................................................................
    assert_nil the_phone_number.phone_number, "07.f: Instance [#{the_user.my_name}],my_work_phone is not a blank phone number"

    # 07.g .....................................................................
    expected = test_phone_type
    assert_equal expected, the_phone_number.phone_type, "07.g: Instance [#{the_user.my_name}],my_work_phone should have the correct type"

    # 07.h .....................................................................
    assert_equal 1, the_user.phone_numbers.size, "07.h: Instance [#{the_user.my_name}] should now have 1 phone number"

    # 07.i .....................................................................
    the_user = users(:has_two_phone)
    assert_equal 2, the_user.phone_numbers.size, "07.i: Instance [#{the_user.my_name}] should have 2 phone numbers"

    # 07.j .....................................................................
    the_phone_number = the_user.my_work_phone
    assert_instance_of PhoneNumber, the_phone_number, "07.j:  [#{the_user.my_name}.my_home_number] should return instance of class PhoneNumber"

    # 07.k .....................................................................
    assert_equal the_user.id, the_phone_number.user_id, "07.k: Instance [#{the_user.my_name}.my_work_phone has an incorrect user_id"

    # 07.l .....................................................................
    expected = PhoneNumber.find_by(user_id: the_user.id, phone_type: test_phone_type).full_number
    assert_equal expected, the_phone_number.full_number, "07.l: Instance [#{the_user.my_name}].my_home_number phone_number is not correct"

    # 07.m .....................................................................
    expected = test_phone_type
    assert_equal expected, the_phone_number.phone_type, "07.m: Instance [#{the_user.my_name}],my_work_phone should have the correct type"
  end ## -- end test --
## TODO - add a test to ensure missing_key_info? is false when there is more than one funded_child
  #-----------------------------------------------------------------------------
  #  Test 08
  # => a) tests that missing_key_info? is true when new instance of User is created
  # => b) tests that missing_key_info? is false when there is an address with a province code and 1 valid funded person
  # => c) tests that missing_key_info? is true when there is an address with a province code and 1 INVALID funded person
  # => d) tests that missing_key_info? is true when there is no address and 1 funded person
  # => e) tests that missing_key_info? is true when there is address, but no province code and 1 funded person
  # => f) tests that missing_key_info? is true when there is address with a province code and no funded people
  testName = '08 Test missing_key_info?'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # 08.a .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    assert the_user.missing_key_info?, "08.a: missing_key_info? should be true for new instance of User"

    # 08.b .....................................................................
    # Ensure all basic info there and the funded person is valid
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('mb').id
    a = ProvinceCode.find the_user.province_code_id
    child = the_user.funded_people.build({name_first: 'Fred', birthdate: '2014-02-04'})
    # puts "child is blank #{child.is_blank?}; child is valid #{child.valid?}"
    # puts child.errors.full_messages
    assert_not the_user.missing_key_info?, "08.b: missing_key_info? should be false when there is a funded_person and address with province"

    # 08.c .....................................................................
    # Ensure all basic info there and the funded person is INVALID (no birthdate)
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('mb').id
    a = ProvinceCode.find the_user.province_code_id
    the_user.funded_people.build({name_first: 'Fred'})
    assert the_user.missing_key_info?, "08.c: missing_key_info? should be true when there is 1 invalid funded_person and address with province"

    # 08.d .....................................................................
    # Funded Person Defined, no address
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.funded_people.build
    assert the_user.missing_key_info?, "08.d: missing_key_info? should be true when there is a funded_person and no address"

    # 08.e .....................................................................
    # Funded Person Defined, Address added, but no province
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.address = ''
    the_user.funded_people.build
    assert the_user.missing_key_info?, "08.e: missing_key_info? should be true when there is a funded_person and an address with no province code"

    # 08.f .....................................................................
    # Funded Person Defined, Address added, but no province
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('mb').id
    assert the_user.missing_key_info?, "08.f: missing_key_info? should be true when there is no funded_person and an address with a province code"
  end ## -- end test08 --

  #-----------------------------------------------------------------------------
  #  Test 09
  # => a) tests that bc_resident? is false when new instance of User is created
  # => b) tests that bc_resident? is false when new instance of User is created, and address is added
  # => c) tests that bc_resident? is false when new instance of User is created, and address is added, and province code set to 'ON'
  # => d) tests that bc_resident? is true when new instance of User is created, and address is added, and province code set to 'BC'
  testName = '09 Test bc_resident?'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # 09.a .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    assert_not the_user.bc_resident?, '09.a: bc_resident? should be false when new instance of User is created'

    # 09.b .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.address = ''
    assert_not the_user.bc_resident?, '09.b: bc_resident? should be false when new instance of User is created, and address is added'

    # 09.c .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('ont').id
    assert_not the_user.bc_resident?, '09.c: bc_resident? should be false when new instance of User is created, and address is added, and province code set to ON'

    # 09.d .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('bc').id
    assert the_user.bc_resident?, '09.d: bc_resident? should be true when new instance of User is created, and address is added, and province code set to BC'
  end ## -- end test09 --

  #-----------------------------------------------------------------------------
  #  Test 10
  # => a) tests that can_create_new_rtp? is false when User has a province of ON and have one funded child
  # => b) tests that can_create_new_rtp? is false when User has a province of BC and have No funded child
  # => c) tests that can_create_new_rtp? is true when User has a province of BC and have one funded child
  testName = '10 Test can_create_new_rtp?'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # 10.a .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('ont').id
    the_user.funded_people.build
    assert_not the_user.can_create_new_rtp?, '10.a: can_create_new_rtp? should be false when User has a province of ON and have one funded child'

    # 10.b .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('bc').id
    assert_not the_user.can_create_new_rtp?, '10.b: can_create_new_rtp? should be false when User has a province of BC and have No funded child'

    # 10.c .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('bc').id
    the_user.funded_people.build
    assert the_user.can_create_new_rtp?, '10.c: can_create_new_rtp? should be true when User has a province of BC and have one funded child'

  end ## -- end test 10 --

  #-----------------------------------------------------------------------------
  #  Test 11
  # => a) tests that can_see_my_home? is false when User is new
  # => b) tests that can_see_my_home? is false when User has an address defined, but no province code, and 1 funded child with 1 invoice
  # => c) tests that can_see_my_home? is false when User has an address defined with a province code of BC, but no  funded child
  # => d) tests that can_see_my_home? is true when User has an address defined with a province code of BC, with 1 funded child and no invoices
  # => e) tests that can_see_my_home? is true when User has an address defined with a province code of BC, with 1 funded child and 1 invoice
  # => f) tests that can_see_my_home? is false when User has an address defined with a province code of ON, with 1 funded child and no invoices
  # => g) tests that can_see_my_home? is true when User has an address defined with a province code of ON, with 1 funded child and 1 invoice
  testName = '11 Test can_see_my_home?'
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # 11.a .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    assert_not the_user.can_see_my_home?, '11.a: can_see_my_home? should be false when User is new'

    # 11.b .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.address = ''
    the_user.funded_people.build
    the_user.funded_people[0].invoices.build
    assert_not the_user.can_see_my_home?, '11.b: can_see_my_home? should be false when be User has an address defined, but no province code, and 1 funded child with 1 invoice'

    # 11.c .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('bc').id
    assert_not the_user.can_see_my_home?, '11.c: can_see_my_home? should be false when User has an address defined with a province code of BC, but no funded child'

    # 11.d .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('bc').id
    the_user.funded_people.build({name_first: 'Fred', birthdate: '2014-02-02'})
    assert the_user.can_see_my_home?, '11.d: can_see_my_home? should be true when User has an address defined with a province code of BC, with 1 funded child and no invoices'

    # 11.e .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('bc').id
    the_user.funded_people.build({name_first: 'Fred', birthdate: '2014-02-02'})
    the_user.funded_people[0].invoices.build
    assert the_user.can_see_my_home?, '11.e: can_see_my_home? should be true when User has an address defined with a province code of BC, with 1 funded child and 1 invoice'

    # 11.f .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('ont').id
    the_user.funded_people.build({name_first: 'Fred', birthdate: '2014-02-02'})
    assert_not the_user.can_see_my_home?, '11.f: can_see_my_home? should be false when User is has an address defined with a province code of ON, with 1 funded child and 0 invoices'

    # 11.g .....................................................................
    the_user = User.new(email: 'me@weenhanceit.com', password: 'secret')
    the_user.province_code_id = province_codes('ont').id
    the_user.funded_people.build({name_first: 'Fred', birthdate: '2014-02-02'})
    the_user.funded_people[0].invoices.build
    assert the_user.can_see_my_home?, '11.g: can_see_my_home? should be true when User is has an address defined with a province code of ON, with 1 funded child and 1 invoices'

  end ## -- end test 11 --


  test 'edit and save one user' do
    #--------------------------------------------------------------------
    # REPLACED LARRY's user_hash as the phone and address are no longer nested
    #   but available in user
    # # skip 'I started to test nested attributes, but it is a rat hole.'
    # user_hash = {
    #   name_first: '1',
    #   name_last: '2',
    #   addresses_attributes: {
    #     a: {
    #       address_line_1: '123456789 Street St',
    #       city: 'Some City',
    #       province_code_id: province_codes(:bc).id,
    #       postal_code: 'S0S 0S0'
    #     }
    #   },
    #   phone_numbers_attributes: {
    #     home: {
    #       phone_number: '5555555555',
    #       phone_type: 'home'
    #     },
    #     work: {
    #       phone_number: '6666666666',
    #       phone_type: 'work'
    #     }
    #   }
    # }
    #--------------------------------------------------------------------
    user_hash = {
       name_first: '1',
       name_last: '2',
       address: '123456789 Street St',
       city: 'Some City',
       province_code_id: province_codes(:bc).id,
       postal_code: 'S0S 0S0',
       home_phone_number: '5555555555',
       work_phone_number: '6666666666'
     }

    user = User.new(email: email = 'me@weenhanceit.com',
                    password: 'password')
    # These are no difference because we pre-create address and phone
    # TODO: Review the above implementation approach.
    assert_difference 'User.count' do
      assert_difference 'Address.count' do
        assert_difference 'PhoneNumber.count', 2 do
          assert user.update(user_hash), -> { user.errors.inspect }
        end
      end
    end

    assert retrieved_user = User.find_by(email: email)
    assert_equal user_hash[:name_last], retrieved_user.name_last
    assert_equal user_hash[:city], retrieved_user.city
    # assert_equal user_hash[:addresses_attributes][:a][:city], retrieved_user.my_address.city
    # user_hash.each do |k, _v|
    #   fixed_key = k.to_s.sub(/_attributes\Z/, '').to_sym
    #   assert_equal user_hash[k], user.send(fixed_key)
    # end
  end

  test 'change postal code and update user' do
    user = prep_user
    user.postal_code = 'V0V 0V1'
    assert user.save
    user.reload
    assert_equal 'V0V0V1', user.postal_code
  end

  test 'change phone number and update user' do
    user = prep_user
    user.home_phone_number = '5555551213'
    assert user.save
    user.reload
    user.home_phone_number = '(555) 555-1213'
  end

  test 'change to invalid postal code and update user' do
    user = prep_user
    assert user.save
    user.postal_code = 'V0V 0V11'
    assert !user.save
    user.reload
    assert_equal 'V0V0V0', user.postal_code
  end

  test 'change to invalid phone number and update user' do
    user = prep_user
    assert user.save
    user.home_phone_number = '55555512133'
    assert !user.save
    user.reload
    user.home_phone_number = '(555) 555-1212'
  end

  private

  def prep_user
    user = User.new(email: 'empty_form@autism-funding.com',
                    password: 'aslk234jakl',
                    name_first: 'Empty',
                    name_last: 'Form')
    user.addresses.build(address_line_1: 'Empty St',
                         city: 'Sadville',
                         province_code: province_codes(:bc),
                         postal_code: 'V0V 0V0')
    user.phone_numbers.build(phone_type: 'Home', phone_number: '5555551212')
    user
  end
end
