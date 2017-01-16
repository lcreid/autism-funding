module InvoicesHelper
  def prep_options(remove_empty, the_object = nil, the_method = nil, add_ons = nil)
    ary = []

    ##-- Inititalize the array with the collection of the_object
    unless the_object.nil? || the_method.nil?
      if the_object.respond_to?(:each)
        the_object.each do |item|
          ary << item.send(the_method).to_s if item.respond_to?(the_method)
        end
      elsif the_object.respond_to?(the_method)
        ary << the_object.send(the_method).to_s
      end
    end

    ##-- Determine if there are any add ons, and if so add the_method
    if add_ons.respond_to?(:each)
      add_ons.each do |a|
        ary << a.to_s
      end
    elsif !add_ons.blank?
      ary << add_ons.to_s
    end

    ##-- Clean up our array
    ary.sort!
    ary.select! { |element| !element.empty? } if remove_empty
    ary.uniq!

    ##-- Return our options
    ary
  end

  ##
  # Return an option list for the selection of RTP corresponding to invoice.
  def rtp_option_list_for_select(invoice)
    options = options_for_select([['Out of Pocket', '']])
    rtps = invoice.match
    # puts "RTPs: #{rtps.inspect}"
    # puts "Invoice has RTP: #{invoice.cf0925.inspect}"
    selected = invoice.cf0925.id if invoice.cf0925
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
