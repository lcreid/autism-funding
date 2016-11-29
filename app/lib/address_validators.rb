module AddressValidators
  extend ActiveSupport::Concern

  included do
    validates :postal_code, format: { with: /\A *[a-zA-Z][0-9][a-zA-Z] *[0-9][a-zA-Z][0-9] *\z/,
                                      message: ' - must be of the format ANA NAN' }, allow_blank: true
  end
end
