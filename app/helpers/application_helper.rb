module ApplicationHelper
  def hash_for_menu
    ## The has for the menu is of the format of {'Menu Item' => link}
    ## The first two characters of the menu items are ignored.  They allow for a
    ## guarentee of the order of the hash.
    ## Note if first two characters are '__', the item will be ignored.  This is
    ## a useless feature - only available to help in testing

    iseq = 0
    the_hash = {"__" => "Menu Hash"}
    #-- The following menu items are available to signed in users
    if user_signed_in?
      ##== User's home page
      the_title = "%02d%s" % [iseq, "My Home"]
      iseq +=1
      if  current_user.my_address.get_province_code == "BC"
        the_hash[the_title ] = "/"
      else
        the_hash[the_title ] = static_non_supported_path
      end

      ##== User's profile page
      the_title = "%02d%s" % [iseq, "My Profile"]
      iseq +=1
      the_hash[the_title ] = my_profile_index_path


      if  current_user.my_address.get_province_code == "BC"
        the_title = "%02d%s" % [iseq, "Help"]
        iseq +=1
        the_hash[the_title ] = static_bc_instructions_path
      end

    end

    #== 'Public' pages
    the_title = "%02d%s" % [iseq, "Other Resources"]
    iseq +=1
    the_hash[the_title ] = other_resources_index_path

    the_title = "%02d%s" % [iseq, "Contact Us"]
    iseq +=1
    the_hash[the_title ] = static_contact_us_path



    return the_hash
  end
end
