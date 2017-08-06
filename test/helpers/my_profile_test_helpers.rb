require 'test_helper'
module MyProfileTestHelper
  class MyProfileTestPage < CapybaraTest
    def initialize(arg)
      # Initialize the input elements in the Edit User Information Panel
      @items = { address: ATextBox.new(id: 'user_address', valid_value: '123 Main St') }
      @items[:name_first] = ATextBox.new(id: 'user_name_first', valid_value: 'Firsty')
      @items[:postal_code] = ATextBox.new(id: 'user_postal_code', valid_value: 'V2a5T2', formatted_valid_value: 'V2A 5T2', chk_validator: true, invalid_value: 'V33 2YA', err_message: ' - must be of the format ANA NAN')
      @items[:work_phone_number] = ATextBox.new(id: 'user_work_phone_number', valid_value: '(604) 765-2134', chk_validator: true, invalid_value: '60476521', formatted_invalid_value: '(6) 047-6521', err_message: ' - must be 10 digit, area code/exchange must not start with 1 or 0')
      @items[:home_phone_number] = ATextBox.new(id: 'user_home_phone_number', valid_value: '(604) 212-6527', chk_validator: true, invalid_value: '604212', err_message: ' - must be 10 digit, area code/exchange must not start with 1 or 0')

      # Add a blank funded child
      @funded_children_array = [FundedPersonTest.new(:blank)]

      super
    end

    # add a funded child to @funded_children_array, just before the end the array
    def add_child(type = :valid)
      # figure out where to insert the new child in the funded children array
      insert_index = @funded_children_array.size - 1
      # puts (@funded_children_array.class)
      @funded_children_array.insert(insert_index, FundedPersonTest.new(type))
      @funded_children_array[insert_index].fill_in_child(insert_index)
      # puts "index: #{insert_index} FIRST NAME: #{@funded_children_array[insert_index].tb_name_first.present_value} "
      # puts "index: #{insert_index} BIRTHDATE: #{@funded_children_array[insert_index].tb_birthdate.present_value} "
      # puts "Added a new child into array at: #{insert_index} Name: #{@funded_children_array[insert_index].tb_name_first.expected_value} "
    end # def add_child

    # Check that the input elements in the form contain the expected values
    def check_form(line, test)
      # Check the input elements in the User Information panel
      test_cnt = 1
      @items.each do |key, item|
        # puts ".. checking #{key} #{test}.#{test_cnt}"
        res = item.check_input
        unless res == ''
          msg = "#{__LINE__} From line: #{line}, Test: #{test}.#{test_cnt} #{key}: - #{res}"
          assert_not msg, msg
          break
        end
        test_cnt += 1
      end

      # Now Check all the funded children
      @funded_children_array.each_with_index do |child, index|
        #  puts "#{__LINE__}: Running through the funded children array Index: #{index} type: #{child.type} name: expected #{child.tb_name_first.expected_value} present: #{child.tb_name_first.expected_value}  .. born: expected #{child.tb_birthdate.expected_value} present: #{child.tb_birthdate.expected_value}"
        res = child.check_the_kid(index)
        unless res == ''
          msg = "#{__LINE__} From line: #{line}, Test: #{test}.#{test_cnt} Funded Child index #{index}: - #{res}"
          assert_not msg, msg
          break
        end
        test_cnt += 1
      end # funded_children_array iteration
    end # end def check_form

    # Checks whether the notifications for the page appear.  Expection for whether
    # the notifications should appear are passed as parameters
    def check_notifications(line, test, not_bc_resident = false, not_enough_info = false)
      test_content = 'The forms and funding found in this area are only availble to residents of British Columbia.'
      if has_text? test_content
        # The notification is present, chack that we expected it
        assert not_bc_resident, "#{__LINE__} From line: #{line}, Test: #{test}.1 notification 'BC residents only' present, but NOT expected"
      else
        # The notification is NOT present, check that we were not expecting it
        assert_not not_bc_resident, "#{__LINE__} From line: #{line}, Test: #{test}.2 notification of 'BC residents only' NOT present, but expected"
      end

      test_content = 'To begin taking advantage of the functionality of this site you must enter the province of your address as well as at least one funded child'
      if has_text? test_content
        # The notification is present, chack that we expected it
        assert not_enough_info, "#{__LINE__} From line: #{line}, Test: #{test}.3 notification 'key info missing' present, but NOT expected"
      else
        # The notification is NOT present, check that we were not expecting it
        assert_not not_enough_info, "#{__LINE__} From line: #{line}, Test: #{test}.4 notification of 'key info missing' NOT present, but expected"
      end
    end # method check_notifications

    # fill in all of the form items.  Not including funded children
    def fill_in_form_items
      @items.each do |_key, item|
        # puts ".. filling in: #{key}"
        item.fill_in_field
        assert true
      end
      ## TODO this hard codes all address to BC addresses
      ## NEED to add a Class to handle drop down boxes
      province = ProvinceCode.find_by(province_code: 'BC')
      select province.province_name, from: 'user_province_code_id'
    end # def fill_in_form_items

    # Get the expected value for a particular :item
    def get_expected_value(item)
      res = @items[item]
      res = res.expected_value unless res.nil?
      res
    end # def get_expected_value

    # passed an array of symbols, sets each item to invalid and all others to valid
    # and re-fills the form
    def set_invalid(list)
      list = [list] unless list.respond_to? :include?
      @items.each do |key, item|
        item.is_valid = if list.include? key
                          false
                        else
                          true
                        end
        fill_in_form_items
      end
    end # def set_invalid

    # Sets a specific item valid
    def set_valid(item)
      @items[item].is_valid = true if @items.key?(item)
    end # def set_valid(item)

    # Sets the item value (valid or invalid) to a new value, and fills this value
    # in the form
    def set_value(item, valid, val, form_val = val)
      item_instance = @items[item]
      unless item_instance.nil?
        if valid == :valid
          item_instance.valid_value = val
          item_instance.formatted_valid_value = form_val
          item_instance.is_valid = true
        elsif valid == :valid
          item_instance.invalid_value = val
          item_instance.formatted_invalid_value = form_val
          item_instance.is_valid = false
        end
        # fill in the item
        item_instance.fill_in_field
      end
    end # def set_value
  end # class MyProfileTestPage

  # ----------------------------------------------------------------------------
  # This class represents one funded child and supports the row of input for the child
  class FundedPersonTest < ActiveSupport::TestCase
    include Capybara::DSL

    def initialize(type = :blank)
      base = Time.now.to_f.to_s # Generate a unique name
      @index = 0
      case type
      when :valid
        @type = :valid
        @tb_name_first = ATextBox.new(valid_value: "First_#{base}")
        @tb_name_middle = ATextBox.new(valid_value: "First_#{base}")
        @tb_name_last = ATextBox.new(valid_value: "First_#{base}")
        @tb_birthdate = ATextBox.new(valid_value: (Date.today - (365 * 10)).strftime('%Y-%m-%d'), chk_validator: true)

      when :invalid
        @type = :invalid
        @tb_name_first = ATextBox.new(valid_value: "First_#{base}")
        @tb_name_middle = ATextBox.new(valid_value: "Middle_#{base}")
        @tb_name_last = ATextBox.new(valid_value: "Last_#{base}")
        ## TODO Test an invalid child
        @tb_birthdate = ATextBox.new(invalid_value: (Date.today + (365 * 2)).strftime('%Y-%m-%d'), chk_validator: true, err_message: "- can't be in the future")

      else
        @type = :blank
        @tb_name_first = ATextBox.new(valid_value: '')
        @tb_name_middle = ATextBox.new(valid_value: '')
        @tb_name_last = ATextBox.new(valid_value: '')
        @tb_birthdate = ATextBox.new(valid_value: '')
      end
    end # def initialize

    attr_reader :type
    attr_accessor :tb_name_first
    attr_accessor :tb_name_middle
    attr_accessor :tb_name_last
    attr_accessor :tb_birthdate

    # This method checks that the child input items are what they are expected to be
    # It returns a string with an error message, or a zero length string, if no errors
    def check_the_kid(frm_index = 0)
      set_ids(frm_index)
      ret = tb_name_first.check_input
      ret == '' && ret = tb_name_middle.check_input
      ret == '' && ret = tb_name_last.check_input
      ret == '' && ret = tb_birthdate.check_input
      ret
    end # def check_the_kid

    # This method fills in a input elements for the child
    def fill_in_child(frm_index)
      set_ids(frm_index)
      @tb_name_first.fill_in_field
      @tb_name_middle.fill_in_field
      @tb_name_last.fill_in_field
      @tb_birthdate.fill_in_field
    end # def fill_in_child

    # This method sets the ID for the input element.  This will be based on the
    # position in the array.  It may change on each render, thus the ids need to
    # be refreshed before any fill-in or check
    def set_ids(frm_index)
      @tb_name_first.id = "user_funded_people_attributes_#{frm_index}_name_first"
      @tb_name_middle.id = "user_funded_people_attributes_#{frm_index}_name_middle"
      @tb_name_last.id = "user_funded_people_attributes_#{frm_index}_name_last"
      @tb_birthdate.id = "user_funded_people_attributes_#{frm_index}_birthdate"
    end # def set_ids
  end # class: FundedPersonTest
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  class ATextBox < ActiveSupport::TestCase
    include Capybara::DSL
    def initialize(init_params)
      init_params = {} unless init_params.class.to_s == 'Hash'

      @id = init_params[:id] || 'default_id'
      @valid_value = init_params[:valid_value] || 'valid'
      @invalid_value = init_params[:invalid_value] || 'invalid'
      @formatted_valid_value = init_params[:formatted_valid_value] || @valid_value
      @formatted_invalid_value = init_params[:formatted_invalid_value] || @invalid_value
      @err_message = init_params[:err_message] || 'error'
      @is_valid = true
      @chk_validator = init_params[:chk_validator] || false
    end # def initialize

    attr_accessor :valid_value
    attr_accessor :invalid_value
    attr_accessor :formatted_valid_value
    attr_accessor :formatted_invalid_value
    attr_accessor :id
    attr_accessor :err_message
    attr_accessor :is_valid

    # This method checks the the contents of the text box are what are expected.
    # It also checks if any error messages are present, if they should be, or
    # not present, if they should not be.
    # If any errors are detected, an error message is returned.  If no errors are
    # detected, a zero length string is returned.
    def check_input
      ret = ''
      if is_valid
        # Text Box Should be valid
        unless present_value == expected_value
          show_me __LINE__
          ret = "Unexpected (Valid) contents expecting: [#{expected_value}], was [#{present_value}]"
        end
        # if self.id == 'user_funded_people_attributes_0_birthdate'
        #   show_me __LINE__
        # end
        if ret == '' && @chk_validator
          if chk_for_error_message?(id, err_message)
            ret = 'Error Message, on valid contents'
          end
        end
      else
        # Text Box Should be invalid
        unless present_value == expected_value
          show_me __LINE__
          ret = "Unexpected (InValid) contents expecting: #{expected_value}, was #{present_value}"
        end
        if ret == '' && @chk_validator
          unless chk_for_error_message?(id, err_message)
            ret = 'No Error Message, on valid contents'
          end
        end
      end
      ret
    end # def check_input()

    # This method checks the page and returns a true if the specificed error message
    # is in a span element following the id
    def chk_for_error_message?(id, message)
      return false unless (res = first("##{id} + span.help-block"))
      res.has_text?(message)
    end # def chk_for_error_message?

    # This method returns the expected value of the text box.  The value depends
    # on whether the valid or invalid value has been set
    def expected_value
      ev = if @is_valid
             @formatted_valid_value
           else
             @formatted_invalid_value
           end
      ev = '' if ev.nil?
      ev
    end # expected value

    # This method will fill in the text box value in the form
    def fill_in_field
      if @is_valid
        fill_in @id, with: @valid_value
      else
        fill_in @id, with: @invalid_value
      end
    end # def fill_in_field

    # Reads the current page and returns the present contents of the text box
    def present_value
      #      puts "-------#{@id}----------------"
      pv = first("##{@id}").value
      pv = '' if pv.nil?
      pv
    end # def present_value

    def show_me(the_line = 0)
      the_line = if the_line > 0
                   the_line.to_s
                 else
                   ''
                 end
      puts "------------#{the_line}----------------------------------"
      puts "--                        id: #{id}"
      puts "--                     valid: #{@is_valid}"
      puts "--             chk_validator: #{@chk_validator}"
      puts "--     valid:            val: #{@valid_value}      formatted: #{@formatted_valid_value}"
      puts "--   invalid:            val: #{@invalid_value}    formatted: #{@formatted_invalid_value}"
      puts "--  expected:            val: [#{expected_value}] class: #{expected_value.class}"
      puts "--     value:            val: [#{present_value}]  class: #{present_value.class}"
      puts '----------------------------------------------'
    end # def show_me
  end # end class def ATextBox
end
