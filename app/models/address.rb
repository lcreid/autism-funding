class Address < ApplicationRecord
  # One record for each address
  # ----- Associations ---------------------------------------------------------
  belongs_to :province_code
  belongs_to :user
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  validates :user_id, presence: true
  validates :province_code_id, presence: true
  validates :postal_code, format: {with:/\A *[a-zA-Z][0-9][a-zA-Z] *[0-9][a-zA-Z][0-9] *\z/,
          message: "Postal Code must be of the format ANA NAN"}, allow_blank: true

  #-----------------------------------------------------------------------------
  # ----- Callbacks ------------------------------------------------------------
  before_save :clean_address
  #-----------------------------------------------------------------------------


  # ----- Public Methods -------------------------------------------------------
  def get_address delimiter:  " "
    clean_address
    #-- Initialize variables -----------------------------
    use_delimiter = ""
    the_address = ""
    #-- Get Address Line 1  -------------------------------
    unless address_line_1.blank?
      the_address = address_line_1
      #---------------------------
      use_delimiter = delimiter
    end
    # -- Add Address line 2, if there
    unless address_line_2.blank?
      the_address = "#{the_address}#{use_delimiter}#{address_line_2}"
    end
    return the_address
  end

  def get_full_address (delimiter:  " ", blank_address: " -- no address -- ")
    clean_address
    the_address_part1 = get_address(delimiter: delimiter)

    the_address_part2 = city
    if the_address_part2.blank?
      the_address_part2 = get_province_code
    else
      the_address_part2 += " #{get_province_code}"
    end

    the_address_part2.strip!
    if the_address_part2.blank?
      the_address_part2 = get_postal_code
    else
      the_address_part2 += "  #{get_postal_code}"
    end
    the_address_part2.strip!

    if ! the_address_part1.blank? && ! the_address_part2.blank?
      the_address = "#{the_address_part1}#{delimiter}#{the_address_part2}"
    elsif ! the_address_part1.blank?
      the_address = the_address_part1
    elsif ! the_address_part2.blank?
      the_address = the_address_part2
    else
      the_address = blank_address
    end



    return the_address
  end
  def get_html_address (style: "font-family: courier; font-size: 10pt; white-space: pre;", blank_address:  " -- no address -- ")
    return "<span style=\"#{style}\">#{get_full_address delimiter: "<br>", blank_address: blank_address }</span>"
  end


  def get_postal_code
    clean_address
    if postal_code.blank?
      ret = ""
    elsif postal_code.length != 6
      ret = "??? ???"
    else
      ret = "#{postal_code[0..2]} #{postal_code[3..5]}"
    end
    return ret
  end



  def get_province_code  #self.province_code.prov_code
    return ( self.province_code.nil? ? "" : self.province_code.province_code )
  end
  def get_province_name
    return ( self.province_code.nil? ? "" : self.province_code.province_name )
  end

  #-----------------------------------------------------------------------------
  # ----- Protected Methods ----------------------------------------------------
  protected
    def clean_address
      unless postal_code.blank?
        postal_code.gsub!(/ /,"")
        postal_code.upcase!
      end
      unless address_line_1.blank?
        address_line_1.strip!
      end
      unless address_line_2.blank?
        address_line_2.strip!
      end
      unless city.blank?
        city.strip!
      end

    end
  #-----------------------------------------------------------------------------

  # ----- Private Methods -------------------------------------------------------
  #-----------------------------------------------------------------------------
end
