class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :province_code, optional: true
  has_many :funded_people
  validates :postal_code, format: { with: /[a-zA-Z][0-9][a-zA-Z][0-9][a-zA-Z][0-9]/,
#    validates :postal_code, format { #with: /\A[a-zA-Z]+\z/}
            message: "Postal Code must be in format: 'ANANAN'" }, length: {is: 6}, allow_blank: true

  validates :province_code, presence: true, if: "! province_code_id.nil?"

  def display_my_name
    my_name ="#{name_first} #{name_middle}".strip
    my_name ="#{my_name} #{name_last}".strip
    if my_name == ""
      my_name = email
    end
    return my_name
  end

  def my_province_code  #self.province_code.prov_code
    return ( self.province_code.nil? ? "" : self.province_code.prov_code )
  end
  def my_postal_code  #self.province_code.prov_code
    return ( postal_code.nil? ? "" : postal_code.upcase )
  end


  def display_address (display_format = :html, style = "")
    #-- Initialize variables -----------------------------
    got_an_address = false
    use_delimiter = ""
    the_address = ""
    address_3 = ""
    if display_format == :html
      delimiter = "<br>"
    else
      delimiter = display_format
    end
    #------------------------------------------------------
    #-- Get Address Line 1  -------------------------------
    if ! address_line_1.blank?
      the_address = address_line_1
      #---------------------------
      got_an_address = true
      use_delimiter = delimiter
    end
    #------------------------------------------------------
  #  the_address += "|#{self.province_codes.province_code}|"
    #-- Get Address Line 2  -------------------------------
    if ! address_line_2.blank?
      the_address += "#{use_delimiter}#{address_line_2}"
      #---------------------------
      got_an_address = true
      use_delimiter = delimiter
    end
    #------------------------------------------------------
    #-- Make Up Address Line 3  ---------------------------
    address_3 = ""
    if ! city.blank?
      address_3 += city
    end
    if ! my_province_code.blank?
      address_3 += " #{my_province_code}"
    end
    if ! my_postal_code.blank?
      address_3 += "  #{my_postal_code}"
    end
    if ! address_3.blank?
      the_address += "#{use_delimiter}#{address_3}"
      #---------------------------
      got_an_address = true
      use_delimiter = delimiter
    end

    #-- Check if we have an address.  If not - supply message
    if ! got_an_address
      the_address = " -- no address available -- "
    end

    #-- if this is :html, then enclose the results in a <span>
    if display_format == :html
      if style.blank?
        use_style = "style=\"font-family: courier; font-size: 10pt; white-space: pre;\""
      else
        use_style = "style=\"#{style}\""
      end
      the_address = "<span #{use_style}>#{the_address}</span>"
    end

    return the_address

  end

end
