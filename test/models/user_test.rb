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

end
