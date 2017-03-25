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
end
