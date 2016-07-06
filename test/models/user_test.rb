require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  #-----------------------------------------------------------------------------
  #  Test 01
  # => a) tests that a User.new will create an object
  # => b) tests that a user instance is valid if no province_code_id is set
  # => c) ensure my_province_code is "" with no province_code_id
  # => d) ensure a save is successful  with no province_code_id
  # => e) tests that a user instance is invalid if bad province_code_id is set
  # => f) ensure my_province_code is "" with bad province_code_ide
  # => g) ensures save fails if invalid is true
  # => h) tests that a user instance is valid if good province_code_id is set
  # => i) ensure my_province_code is correct with good province_code_id
  # => j) ensure a save is successful if valid? is true
  testName = "01 Check my_province_code"
  puts "-- Test: #{testName} -----------------------------------"
  test testName do
    # 01.a .....................................................................
    the_user = User.new
    assert_not_nil the_user

    # 01.b .....................................................................
    # add an email and password (only province code will impact validations)
    the_user.email = "info@autism-funding.com"
    the_user.password = "secret"
    assert the_user.valid?, "User instance should be valid with no province_code_id"

    # 01.c .....................................................................
    assert_equal the_user.my_province_code,"", "my_provincel_code should be "" with no postal_code_id"

    # 01.d .....................................................................
    assert the_user.save, "Save of an instance with no province_code_id should succeed"

    # 01.e .....................................................................
    bad_id = 74
    the_user.province_code_id = bad_id
    assert_not the_user.valid?, "User instance should not be valid with bad province_code_id"
#    the_user.errors.messages.each do |m|
#      puts "An error: #{m} id: #{the_user.province_code_id}"
#        end

    # 01.f .....................................................................
    assert_equal the_user.my_province_code,"", "my_province_code should be "" with bad province_code_id"

    # 01.g .....................................................................
    assert_not the_user.save, "Save of an invalid instance should fail"

    # 01.h .....................................................................
    objPC = province_codes(:bc)
    the_user.province_code = objPC
    assert the_user.valid?, "User instance should be valid with good province_code"

    # 01.i .....................................................................
    assert_equal the_user.my_province_code,"#{objPC.prov_code}", "my_provincel_code should match what we set"

    # 01.j .....................................................................
    assert the_user.save, "Save of an valid instance should succeed"

  end


  #-----------------------------------------------------------------------------
  #  Test 02
  # => a) test that no address returns " -- no address available -- "
  # => b) tests that a user instance is valid with a valid postal code
  # => c) Check city and postal code format
  # => d) Check city, province and postal code format
  # => e) Check addr1, city, province and postal code format
  # => f) Check addr1, addr2, city, province and postal code format
  # => g) Test user is still valid
  # => h) Test user can be saved
  testName = "02 Check display_address, non-HTML"
  puts "-- Test: #{testName} -----------------------------------"
  test testName do
    use_del = "|"
    valid_postal_code = "k2b5p6"
    use_addr1 = "43 Norton Ave"
    use_addr2 = "Unit 707"
    use_city = "Ottawa"
    use_prov = province_codes(:ont)
    # 02.a .....................................................................
    the_user = User.new
    # add an email and password (only province code will impact validations)
    the_user.email = "info@autism-funding.com"
    the_user.password = "secret"
    expected = " -- no address available -- "
    assert_equal expected, the_user.display_address(use_del), "display_address should return 'no address' message"

    # 02.b .....................................................................
    the_user.postal_code = valid_postal_code
    assert the_user.valid?, "User instance should be valid with good postal_code"

    # 02.c .....................................................................
    the_user.city = "Ottawa"
    expected = "#{use_city}  #{valid_postal_code.upcase}"
    assert_equal expected, the_user.display_address(use_del), "unexpected address format for city, postal code"

    # 02.d .....................................................................
    the_user.province_code = use_prov
    expected = "#{use_city} #{use_prov.prov_code}  #{valid_postal_code.upcase}"
    assert_equal expected, the_user.display_address(use_del), "unexpected address format for city, prov, postal code"

    # 02.e .....................................................................
    the_user.address_line_1 = use_addr1
    expected = "#{use_addr1}#{use_del}#{use_city} #{use_prov.prov_code}  #{valid_postal_code.upcase}"
    assert_equal expected, the_user.display_address(use_del), "unexpected address format for A1, city, prov, postal code"

    # 02.f .....................................................................
    # Change delimiter to make sure that works
    use_del = "::"

    the_user.address_line_2 = use_addr2
    expected = "#{use_addr1}#{use_del}#{use_addr2}#{use_del}#{use_city} #{use_prov.prov_code}  #{valid_postal_code.upcase}"
    assert_equal expected, the_user.display_address(use_del), "unexpected address format for A1, A2, city, prov, postal code"

    # 02.g .....................................................................
    assert the_user.valid?, "Record should be valid"


    # 02.h .....................................................................
    assert the_user.save, "Save of an valid instance should succeed"


###########################################################
#puts "We are at line ??? Valid: #{the_user.valid?}"
#        the_user.errors.messages.each do |m|
#          puts "An error: #{m}"
#    end
##################################################################
  end

  #-----------------------------------------------------------------------------
  #  Test 03
  # => a) test that no address returns " -- no address available -- "
  # => b) tests that a user instance is valid with a valid postal code
  # => c) Check city and postal code format
  # => d) Check city, province and postal code format
  # => e) Check addr1, city, province and postal code format (spec style)
  # => f) Check addr1, addr2, city, province and postal code format (spec style)
  # => g) Test user is still valid
  # => h) Test user can be saved
  testName = "03 Check display_address, HTML"
  puts "-- Test: #{testName} -----------------------------------"
  test testName do
    use_del = :html
    html_del = "<br>"
    valid_postal_code = "k2b5p6"
    use_addr1 = "43 Norton Ave"
    use_addr2 = "Unit 707"
    use_city = "Ottawa"
    use_style = "color: red"
    standard_style = "font-family: courier; font-size: 10pt; white-space: pre;"
    use_prov = province_codes(:ont)
    # 03.a .....................................................................
    the_user = User.new
    # add an email and password (only province code will impact validations)
    the_user.email = "info@autism-funding.com"
    the_user.password = "secret"
    expected = "<span style=\"#{standard_style}\"> -- no address available -- </span>"
    assert_equal expected, the_user.display_address(use_del), "display_address should return 'no address' message"

    # 03.b .....................................................................
    the_user.postal_code = valid_postal_code
    assert the_user.valid?, "User instance should be valid with good postal_code"

    # 03.c .....................................................................
    the_user.city = "Ottawa"
    expected = "#{use_city}  #{valid_postal_code.upcase}"
    expected = "<span style=\"#{standard_style}\">#{expected}</span>"
    assert_equal expected, the_user.display_address(use_del), "unexpected address format for city, postal code"

    # 03.d .....................................................................
    the_user.province_code = use_prov
    expected = "#{use_city} #{use_prov.prov_code}  #{valid_postal_code.upcase}"
    expected = "<span style=\"#{standard_style}\">#{expected}</span>"
    assert_equal expected, the_user.display_address(use_del), "unexpected address format for city, prov, postal code"

    # 03.e .....................................................................
    the_user.address_line_1 = use_addr1
    expected = "#{use_addr1}#{html_del}#{use_city} #{use_prov.prov_code}  #{valid_postal_code.upcase}"
    expected = "<span style=\"#{use_style}\">#{expected}</span>"
    assert_equal expected, the_user.display_address(use_del,use_style), "unexpected address format for A1, city, prov, postal code"

    # 03.f .....................................................................
    the_user.address_line_2 = use_addr2
    expected = "#{use_addr1}#{html_del}#{use_addr2}#{html_del}#{use_city} #{use_prov.prov_code}  #{valid_postal_code.upcase}"
    expected = "<span style=\"#{use_style}\">#{expected}</span>"
    assert_equal expected, the_user.display_address(use_del,use_style), "unexpected address format for A1, A2, city, prov, postal code"
    expected = "<span style=\"#{standard_style}\">#{expected}</span>"

    # 03.g .....................................................................
    assert the_user.valid?, "Record should be valid"

    # 03.h .....................................................................
    assert the_user.save, "Save of an valid instance should succeed"





puts "We are at line 87 Valid: #{the_user.valid?}"
        the_user.errors.messages.each do |m|
          puts "An error: #{m}"
    end


#  test "Create Blank User" do
#    the_user = User.new
#
#    assert_not_nil the_user
#    the_user.postal_code = "K2B5P6"
#    the_user.address_line_1 = "860 Norton Ave"
#    the_user.address_line_2 = "Unit 7"
#    the_user.province_code_id = 4
#    puts the_user.display_address :html
#    a=the_user.province_code
#    puts "Er we nil: #{a.nil?}"
#  #  the_user.save

#    the_provs = ProvinceCode.all
#    puts "Province Size: #{the_provs.size}"

#    puts "Province: #{the_user.province_code.size}"
  end


  #-----------------------------------------------------------------------------
  #  Test 04
  # => a) Test No Name"
  # => b) Test First Only
  # => c) Test Last Only
  # => d) Middle Only
  # => e) Check First and Last
  # => f) Check First, Middle and Last
  # => g) Test user is still valid
  # => h) Test user can be saved
  testName = "04 Check display_my_name"
  puts "-- Test: #{testName} -----------------------------------"
  test testName do
    first_name = "first"
    middle_name = "middle"
    last_name = "last"
    # 04.a .....................................................................
    the_user = User.new
    # add an email and password (only province code will impact validations)
    the_user.email = "info@autism-funding.com"
    the_user.password = "secret"
    expected = "#{the_user.email}"
    assert_equal expected, the_user.display_my_name, "display_my_name should return email"

    # 04.b .....................................................................
    the_user.name_first = first_name
    the_user.name_middle = nil
    the_user.name_last = nil
    expected = "#{first_name}"
    assert_equal expected, the_user.display_my_name, "display_my_name should return first name"

    # 04.c .....................................................................
    the_user.name_first = nil
    the_user.name_middle = middle_name
    the_user.name_last = nil
    expected = "#{middle_name}"
    assert_equal expected, the_user.display_my_name, "display_my_name should return middle name"

    # 04.d .....................................................................
    the_user.name_first = nil
    the_user.name_middle = nil
    the_user.name_last = last_name
    expected = "#{last_name}"
    assert_equal expected, the_user.display_my_name, "display_my_name should return last name"

    # 04.e .....................................................................
    the_user.name_first = first_name
    the_user.name_middle = nil
    the_user.name_last = last_name
    expected = "#{first_name} #{last_name}"
    assert_equal expected, the_user.display_my_name, "display_my_name should return first and last name"

    # 04.f .....................................................................
    the_user.name_first = first_name
    the_user.name_middle = middle_name
    the_user.name_last = last_name
    expected = "#{first_name} #{middle_name} #{last_name}"
    assert_equal expected, the_user.display_my_name, "display_my_name should return all names"

    # 04.g .....................................................................
    assert the_user.valid?, "Record should be valid"

    # 04.h .....................................................................
    assert the_user.save, "Save of an valid instance should succeed"

  end



end
