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
    puts "Option list match: #{invoice.match}"
    options_from_collection_for_select(invoice.match,
                                       :id,
                                       :to_s,
                                       invoice.cf0925)
  end
end
