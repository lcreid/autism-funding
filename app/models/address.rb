class Address < ApplicationRecord
  include AddressValidators

  # One record for each address
  # ----- Associations ---------------------------------------------------------
  belongs_to :province_code, optional: true
  # You have to provide inverse_of on User for nested attributes to work.
  # Doing it here just in case.
  belongs_to :user, inverse_of: :addresses
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  # LCR had to remove the following validation to make nested attributes work.
  # validates :user_id, presence: true
  # validates :province_code_id, presence: true

  validates :address_line_1,
    :city,
    :postal_code,
    presence: true,
    on: :printable

  #-----------------------------------------------------------------------------
  # ----- Callbacks ------------------------------------------------------------
  before_save :clean_address
  #-----------------------------------------------------------------------------

  # ----- Public Methods -------------------------------------------------------

  def get_address(delimiter: " ")
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
    the_address
  end

  def get_full_address(delimiter: " ", blank_address: " -- no address -- ")
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

    if !the_address_part1.blank? && !the_address_part2.blank?
      the_address = "#{the_address_part1}#{delimiter}#{the_address_part2}"
    elsif !the_address_part1.blank?
      the_address = the_address_part1
    elsif !the_address_part2.blank?
      the_address = the_address_part2
    else
      the_address = blank_address
    end

    the_address
  end

  def get_html_address(style: "font-family: courier; font-size: 10pt; white-space: pre;", blank_address: " -- no address -- ")
    "<span style=\"#{style}\">#{get_full_address delimiter: '<br>', blank_address: blank_address}</span>"
  end

  def get_postal_code
    clean_address
    ret = if postal_code.blank?
            ""
          elsif postal_code.length != 6
            "??? ???"
          else
            "#{postal_code[0..2]} #{postal_code[3..5]}"
          end
    ret
  end

  def get_province_code # self.province_code.prov_code
    (province_code.nil? ? "" : province_code.province_code)
  end

  def get_province_name
    (province_code.nil? ? "" : province_code.province_name)
  end

  def printable?
    # valid?(:printable) || pp(errors.full_messages)
    valid?(:printable)
  end

  #-----------------------------------------------------------------------------
  # ----- Protected Methods ----------------------------------------------------

  protected

  def clean_address
    self.postal_code = postal_code.delete(" ").upcase unless postal_code.blank?
    self.address_line_1 = address_line_1.strip unless address_line_1.blank?
    self.address_line_2 = address_line_2.strip unless address_line_2.blank?
    self.city = city.strip unless city.blank?
  end
  #-----------------------------------------------------------------------------

  # ----- Private Methods -------------------------------------------------------
  #-----------------------------------------------------------------------------
end
