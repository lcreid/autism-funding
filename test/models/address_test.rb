require 'test_helper'
class AddressTest < ActiveSupport::TestCase
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that a Address.new will create an instance of the object
  # => b) tests that the new Address object instance is of the class Address
  # => c) tests that a address instance is invalid if user is not set
  # => d) tests that a address instance is invalid if postal code is invalid
  # => f) tests that a user instance is valid if user set and province code set
  # => g) ensure a save is successful if valid? is true
  testName = "01 Check Address can be created and saved"
  #puts "-- Test: #{testName} -----------------------------------"
  test testName do
    valid_user = users(:basic)
    valid_postal_code = " A2A 3F7 "
    invalid_postal_code = " AxA 3F7 "


    # 01.a .....................................................................
    the_address = Address.new
    assert_not_nil the_address, "01.a: Instance of Address Should not be nil"

    # 01.b .....................................................................
    assert_instance_of Address, the_address, "01.b: Address instance should be of Class Address"

    # 01.c .....................................................................
    the_address.user = nil
    the_address.postal_code = valid_postal_code
    assert_not the_address.valid?, "01.c: the_address should not be valid (No user)"

    # 01.e .....................................................................
    the_address.user = valid_user
    the_address.postal_code = invalid_postal_code
    assert_not the_address.valid?, "01.d: the_address should not be valid (Invalid postal code)"

    # 01.f .....................................................................
    the_address.user = valid_user
    the_address.postal_code = valid_postal_code
    assert the_address.valid?, "01.f: the_address should be valid ( user and valid postal code)"

    # 01.g .....................................................................
    assert the_address.save, "Save of an valid instance should succeed"
  end

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a) test get_postal_code with blank address  "
  # => b) test get_province_code with blank address  "
  # => c) test get_province_name with blank address  "
  # => d) test get_address  with blank address  "
  # => e) test get_full_address with blank address  "
  # => f) test get_html_address with blank address  "
  testName = "02 Check Address format methods - no address specified"
  # puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_address = Address.new
    test_style = "color: red;"
    test_blank_address_text = "no address defined"

    # 02.a .....................................................................
    expected = ""
    assert_equal expected, test_address.get_postal_code, "02.a: get_postal_code error"

    # 02.b .....................................................................
    expected = ""
    assert_equal expected, test_address.get_province_code, "02.b: get_province_code error"

    # 02.c .....................................................................
    expected = ""
    assert_equal expected, test_address.get_province_name, "02.c: get_province_name error"

    # 02.d .....................................................................
    expected = ""
    assert_equal expected, test_address.get_address, "02.d: get_address error"

    # 02.e .....................................................................
    expected = " -- no address -- "
    assert_equal expected, test_address.get_full_address, "02.e: get_full_address error"

    # 02.f .....................................................................
    expected = "<span style=\"#{test_style}\">#{test_blank_address_text}</span>"
    assert_equal expected, test_address.get_html_address(blank_address: test_blank_address_text, style: test_style), "02.f: get_html_address error"
  end   #-- end test -----------------------------------------------------------

  #-----------------------------------------------------------------------------
  #  Test 02
  # => a) test get_postal_code - get properly formatted postal code"
  # => b) test get_postal_code - ensure postal_code has been cleaned up"
  # => c) test get_full_address with just postal code
  # => d) test get_province_code
  # => e) test get_province_name
  # => f) test get_full_address with province & postal code
  # => g) test get_full_address with city, province & postal code
  # => h) test get address with address_line_2 set
  # => i) test address_line_2 cleaned up
  # => j) test get address with address_line_1, address_line_2 set
  # => k) test address_line_1 cleaned up
  # => g) test get_full_address with address_line_1, address_line_2, city, province & postal code
  testName = "03 Check Address format methods"
  puts "-- Test: #{testName} -----------------------------------"
  test testName do
    test_address = Address.new
    test_style = "color: red;"
    test_blank_address_text = "no address defined"
    test_postal_code = "   k2b         6p7"
    expected_postal_code = "K2B 6P7"
    test_province = province_codes(:ont)
    test_city = "  Port Hope     "
    test_address1 = " 680 Norton Ave  "
    test_address2 = "  Unit 707   "
    test_delimiter = " | "

    # 03.a .....................................................................
    test_address.postal_code = test_postal_code
    expected = "#{expected_postal_code}"
    assert_equal expected, test_address.get_postal_code, "03.a: get_postal_code error"

    # 03.b .....................................................................
    expected = "#{expected_postal_code.gsub(/ /,"")}"
    assert_equal expected, test_address.postal_code, "03.b: postal_code not cleaned properly"

    # 02.c .....................................................................
    expected = "#{expected_postal_code}"
    assert_equal expected, test_address.get_full_address, "03.c: get_full_address error (only postal_code)"

    # 03.d .....................................................................
    test_address.province_code = test_province
    expected = "#{test_province.province_code}"
    assert_equal expected, test_address.get_province_code, "03.d: get_province_code error"

    # 03.e .....................................................................
    test_address.province_code = test_province
    expected = "#{test_province.province_name}"
    assert_equal expected, test_address.get_province_name, "03.e: get_province_name error"

    # 03.f .....................................................................
    expected = "#{test_province.province_code}  #{expected_postal_code}"
    assert_equal expected, test_address.get_full_address, "03.f: get_full_address error (province/postal_code)"

    # 03.g .....................................................................
    test_address.city = test_city
    expected = "#{test_city.strip} #{test_province.province_code}  #{expected_postal_code}"
    assert_equal expected, test_address.get_full_address, "03.g: get_full_address error (city/province/postal_code)"

    # 03.g .....................................................................
    expected = "#{test_city.strip}"
    assert_equal expected, test_address.city, "03.g: city not cleaned up"

    # 03.h .....................................................................
    test_address.address_line_2 = test_address2
    expected = "#{test_address2.strip}"
    assert_equal expected, test_address.get_address, "03h: get_address error (address_line_2)"

    # 03.i .....................................................................
    expected = "#{test_address2.strip}"
    assert_equal expected, test_address.address_line_2, "03.i: address_line_2 not cleaned up"

    # 03.j .....................................................................
    test_address.address_line_1 = test_address1
    expected = "#{test_address1.strip} #{test_address2.strip}"
    assert_equal expected, test_address.get_address, "03j: get_address error (address_line_1, address_line_2)"

    # 03.k .....................................................................
    expected = "#{test_address1.strip}"
    assert_equal expected, test_address.address_line_1, "03.k: address_line_1 not cleaned up"

    # 03.l .....................................................................
    expected = "#{test_address1.strip}#{test_delimiter}#{test_address2.strip}#{test_delimiter}#{test_city.strip} #{test_province.province_code}  #{expected_postal_code}"
    assert_equal expected, test_address.get_full_address( delimiter: test_delimiter), "03.l: get_full_address error (address_line_1, address_line_2,city/province/postal_code)"

  end   #-- end test -----------------------------------------------------------


end
