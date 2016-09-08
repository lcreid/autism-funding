class PhoneNumber < ApplicationRecord
  # One record for each phone number
  # ----- Associations ---------------------------------------------------------
  # You have to provide inverse_of on User for nested attributes to work.
  # Doing it here just in case.
  belongs_to :user, inverse_of: :phone_numbers
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  validates :phone_number,
            format: {
              # with: /\A *[2-9][0-9][0-9] *[2-9][0-9][0-9] *[0-9][0-9][0-9][0-9] *\z/,
              with: /\A\s*\(?[2-9]\d{2}\)?[-. \t]*[2-9]\d{2}[-. \t]*\d{4}\s*\z/,
              message: '- must be 10 digit, ' \
                       'area code/exchange must not start with 1 or 0'
            },
            allow_blank: true

  validates :phone_extension,
            format: {
              without: /[^0-9 ]/,
              message: '- must be digits only'
            },
            allow_blank: true

  validates :phone_type, presence: true
  #-----------------------------------------------------------------------------
  # ----- Callbacks ------------------------------------------------------------
  before_save :clean_numbers
  #-----------------------------------------------------------------------------

  # ----- Public Methods -------------------------------------------------------
  def full_number
    if phone_number.blank?
      ret = ''
    else
      ret = "(#{area_code}) #{exchange_subscriber_number}#{extension_number}"
    end
    ret
  end

  def formatted_phone_number
    full_number
  end

  def area_code
    clean_numbers
    ret = if phone_number.blank?
            ''
          elsif /[^0-9]/ =~ phone_number || phone_number.length != 10
            '???'
          else
            phone_number[0..2]
          end
    ret
  end

  def exchange_subscriber_number
    clean_numbers
    ret = if phone_number.blank?
            ''
          elsif /[^0-9]/ =~ phone_number || phone_number.length != 10
            '???-????'
          else
            "#{phone_number[3..5]}-#{phone_number[6..9]}"
          end
    ret
  end

  def extension_number
    clean_numbers
    ret = if phone_extension.blank?
            ''
          elsif /[^0-9]/ =~ phone_extension
            ' x???'
          else
            " x#{phone_extension}"
          end
    ret
  end

  #-----------------------------------------------------------------------------
  # ----- Protected Methods ----------------------------------------------------

  protected

  def clean_numbers
    self.phone_number = phone_number.gsub(/[\(\)-. \t]/, '') unless phone_number.blank?
    self.phone_extension = phone_extension.delete(' ') unless phone_extension.blank?
    self.phone_type = phone_type.strip unless phone_type.blank?
  end
  #-----------------------------------------------------------------------------
  # ----- Private Methods ------------------------------------------------------
  #-----------------------------------------------------------------------------
end
