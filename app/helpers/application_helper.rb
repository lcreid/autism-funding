module ApplicationHelper
  def hash_for_menu
    ## The has for the menu is of the format of {'Menu Item' => link}
    ## The first two characters of the menu items are ignored.  They allow for a
    ## guarentee of the order of the hash.
    ## Note if first two characters are '__', the item will be ignored.  This is
    ## a useless feature - only available to help in testing

    iseq = 0
    the_hash = { "__" => "Menu Hash" }
    #-- The following menu items are available to signed in users
    if user_signed_in?
      ##== User's home page
      #       Note home page is only available to BC residents, or users
      #       who have entered a province and have invoices &or RTPs
      # puts "can see home? #{current_user.can_see_my_home?} Current User: #{current_user.inspect}"
      if current_user.can_see_my_home?
        # puts "#{__LINE__} HERE!"
        the_title = "%02d%s" % [iseq, "My Home"]
        the_hash[the_title] = "/"
        iseq += 1
      end
      ##== User's profile page
      the_title = "%02d%s" % [iseq, "My Profile"]
      iseq += 1
      the_hash[the_title] = my_profile_edit_path
    end

    #== 'Public' pages
    the_title = "%02d%s" % [iseq, "Help"]
    iseq += 1
    the_hash[the_title] = static_bc_instructions_path

    the_title = "%02d%s" % [iseq, "Other Resources"]
    iseq += 1
    the_hash[the_title] = other_resources_index_path

    the_title = "%02d%s" % [iseq, "Contact Us"]
    iseq += 1
    the_hash[the_title] = static_contact_us_path

    the_hash
  end

  # From: http://railscasts.com/episodes/30-pretty-page-title
  def title(page_title)
    content_for(:title) { page_title }
  end
end
