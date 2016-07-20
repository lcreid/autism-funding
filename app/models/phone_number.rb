class PhoneNumber < ApplicationRecord
  # One record for each phone number
  # ----- Associations ---------------------------------------------------------
  belongs_to :user
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  validates :phone_number, format: {with:/\A *[2-9][0-9][0-9] *[2-9][0-9][0-9] *[0-9][0-9][0-9][0-9] *\z/,
          message: "Phone Number must be 10 digit, area code/exchange must not start with 1 or 0"}, presence: true

  validates :phone_extension, format: {without: /\A[0-9] /, message: "Extension must be digits only"}, allow_blank: true

  validates :phone_type, presence: true
  #-----------------------------------------------------------------------------
  # ----- Callbacks ------------------------------------------------------------
  before_save :clean_numbers
  #-----------------------------------------------------------------------------

  # ----- Public Methods -------------------------------------------------------
  def full_number
    if phone_number.blank?
      ret = ""
    else
      ret = "(#{area_code}) #{exchange_subscriber_number}#{extension_number}"
    end
    return ret
  end
  def area_code
    clean_numbers
    if phone_number.blank?
      ret = ""
    elsif /[^0-9 ]/ =~ phone_number || phone_number.length != 10
      ret = "???"
    else
      ret = phone_number[0..2]
    end
    return ret
  end
  def exchange_subscriber_number
    clean_numbers
    if phone_number.blank?
      ret = ""
    elsif /[^0-9 ]/ =~ phone_number || phone_number.length != 10
      ret = "???-????"
    else
      ret = "#{phone_number[3..5]}-#{phone_number[6..9]}"
    end
    return ret
  end
  def extension_number
    clean_numbers
    if phone_extension.blank?
      ret = ""
    elsif /[^0-9 ]/ =~ phone_extension
      ret = " x ???"
    else
      ret = " x#{phone_extension}"
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # ----- Protected Methods ----------------------------------------------------
  protected
    def clean_numbers
      unless phone_number.blank?
        phone_number.gsub!(/ /,"")
      end
      unless phone_extension.blank?
        phone_extension.gsub!(/ /,"")
      end
      unless phone_type.blank?
        phone_type.strip!
      end

    end

  #-----------------------------------------------------------------------------
  # ----- Private Methods -------------------------------------------------------
  #-----------------------------------------------------------------------------
end
