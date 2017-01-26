module InvoicesHelper
  def prep_options(the_object = nil, add_ons = nil)
    ary = []

    ##-- Determine if there are any add ons, and if so add the_method
    if add_ons.respond_to?(:each)
      add_ons.each do |a|
        ary << a.to_s
      end
    elsif !add_ons.blank?
      ary << add_ons.to_s
    end

    ary += the_object.possible_payees

    ary
  end

  ##
  # Return an option list for the selection of RTP corresponding to invoice.
  def rtp_option_list_for_select(invoice)
    options = options_for_select([['Out of Pocket', '']])
    rtps = invoice.match
    # puts "RTPs: #{rtps.inspect}"
    # puts "Invoice has RTP: #{invoice.cf0925.inspect}"
    # FIXME: Hacking this for now (fake it till you make it)
    selected = invoice.cf0925s.first.id if invoice.cf0925s.present?
    # puts "First RTP selected: #{selected}"
    selected ||= rtps[0].id if rtps.size == 1
    # puts "Second RTP selected: #{selected}"
    # puts "Option list match: #{rtps}"
    options += options_from_collection_for_select(rtps,
                                                  :id,
                                                  :to_s,
                                                  selected)
    # puts "OPTIONS: #{options}"
    options
  end
end
