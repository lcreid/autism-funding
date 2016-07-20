class PhoneNumber < ApplicationRecord
  # One record for each phone number
  # ----- Associations ---------------------------------------------------------
  belongs_to :user
  #-----------------------------------------------------------------------------
  # ----- validations ----------------------------------------------------------
  # <<<<<<< HEAD
  #   validates :phone_number, format: {with:/\A *[2-9][0-9][0-9] *[2-9][0-9][0-9] *[0-9][0-9][0-9][0-9] *\z/,
  #           message: "Phone Number must be 10 digit, area code/exchange must not start with 1 or 0"}, presence: true
  #
  #   validates :phone_extension, format: {without: /\A[0-9] /, message: "Extension must be digits only"}, allow_blank: true
  #
  #   validates :phone_type, presence: true
  # =======
  validates :phone_number,
            format: {
              with: /\A *[2-9][0-9][0-9] *[2-9][0-9][0-9] *[0-9][0-9][0-9][0-9] *\z/,
              message: 'Phone Number must be 10 digit, ' \
                       'area code/exchange must not start with 1 or 0'
            },
            presence: true

  validates :phone_extension,
            format: {
              without: /\A[0-9] /,
              message: 'Extension must be digits only'
            },
            allow_blank: true

  validates :phone_type, presence: true
  # >>>>>>> pdf
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

  def area_code
    clean_numbers
    ret = if phone_number.blank?
            ''
          elsif /[^0-9 ]/ =~ phone_number || phone_number.length != 10
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
          elsif /[^0-9 ]/ =~ phone_number || phone_number.length != 10
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
          elsif /[^0-9 ]/ =~ phone_extension
            ' x ???'
          else
            " x#{phone_extension}"
          end
    ret
  end

  #-----------------------------------------------------------------------------
  # ----- Protected Methods ----------------------------------------------------

  protected

  def clean_numbers
    phone_number.delete!(' ') unless phone_number.blank?
    phone_extension.delete!(' ') unless phone_extension.blank?
    phone_type.strip! unless phone_type.blank?
  end
  #-----------------------------------------------------------------------------
  # ----- Private Methods ------------------------------------------------------
  #-----------------------------------------------------------------------------
end
