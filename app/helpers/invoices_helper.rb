module InvoicesHelper
  def prep_options(remove_empty, the_object = nil, the_method = nil, add_ons = nil)
    ary = Array.new

    ##-- Inititalize the array with the collection of the_object
    unless the_object == nil || the_method == nil
      if the_object.respond_to?(:each)
        the_object.each do |item|
          if item.respond_to?(the_method)
            ary << item.send(the_method).to_s
          end
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
    elsif ! add_ons.blank?
      ary << add_ons.to_s
    end

    ##-- Clean up our array
    ary.sort!
    if remove_empty
      ary.select! {|element| ! element.empty?}
    end
    ary.uniq!

    ##-- Return our options
    return ary
  end
end
