require 'test_helper'
module MyProfileTestHelper
  class CheckRTP
    include TestSessionHelpers
    include Capybara::DSL
    include Capybara::Assertions

    def allocation_row
      find(".test-req-#{@amount_requested.to_i}")
    end

    def initialize
      @amount_requested = 0
      @amount_from_this_invoice = 0
      @expected_amount_available = '%.2f' % 0
      @expected_amount = '%.2f' % 0
      @expected_out_of_pocket = '%.2f' % 0

    end

    attr_reader :amount_from_this_invoice
    attr_accessor :amount_requested
    attr_reader :expected_amount_available
    attr_reader :expected_amount
    attr_reader :expected_out_of_pocket

    def set_amount_from_this_invoice amt
      if amt >= 0 && @amount_requested > 0
        @amount_from_this_invoice = '%.2f' % amt
        within allocation_row do
          fill_in('Amount', with: @amount_from_this_invoice)
        end
      else
        puts "DID NTO SET AMOUNT amt: #{amt} @amount_requested: #{@amount_requested}"
      end
    end

    def set_invoice_fields_to_match_rtp rtp
      fill_in 'Service End', with: rtp.service_provider_service_end
      select rtp.service_provider_name, from: 'invoice_invoice_from'
    end

    def set_invoice_fields_to_not_match_rtp rtp
      fill_in 'Service End', with: rtp.service_provider_service_end + 1.day
      select rtp.service_provider_name, from: 'invoice_invoice_from'
    end


    def set_expected_amount amt, format = '%.2f'
      @expected_amount = format_output amt, format
    end

    def set_expected_amount_available amt, format = '%.2f'
      @expected_amount_available = format_output amt, format
    end

    def set_expected_out_of_pocket amt, format = '%.2f'
      @expected_out_of_pocket = format_output amt, format
    end

    def format_output val, frm_str
      # puts "#{__LINE__}: val: [#{val}] frm_str: [#{frm_str}]"
      ret = val
      unless frm_str == '' || ret == ''
        ret = val.to_s
        ret = ret.to_f
        ret = frm_str % val
      end
      # puts "#{__LINE__}: returning: [#{val}]"
      ret.to_s
      ret.strip
    end
  end
end
