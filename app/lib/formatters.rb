##
# Helpers to format various types of data. The helpers in this module
# can be included anywhere, so it's useful for formatting that needs to be
# done in views, controllers, or models.
module Formatters
  ##
  # If the input string looks like a Canadian postal code, format it the
  # official way. Otherwise, leave it untouched.
  def format_postal_code(postal_code)
    match = match_postal_code(postal_code)

    if match
      match[:fsa].upcase + ' ' + match[:ldu].upcase
    else
      postal_code
    end
  end

  ##
  # Return the regular expression match if the input looks like it could be a
  # Canadian postal code. The match has the first three characters in
  # `match_postal_code[:fsa]`, and the last three characters in
  # `match_postal_code[:ldu]`
  def match_postal_code(postal_code)
    /\A\s*(?<fsa>[a-zA-Z]\d[a-zA-Z])\s*(?<ldu>\d[a-zA-Z]\d)\s*\z/
      .match(postal_code)
  end

  ##
  # Return the regular expression match if the input looks like it could be
  # a Canadian or U.S. phone number. The match has the area code in
  # `match_phone_number[:area_code]`, the exchange (next three digits) in
  # `match_phone_number[:exchange]`, the rest of the number in
  # `match_phone_number[:number]`, and the extension, if any, in
  # `match_phone_number[:ext]`
  def match_phone_number(number)
    /\A\s*\(?\s*?(?<area_code>\d{3})\s*\)?[-.\s]*(?<exchange>\d{3})[-.\s]*(?<number>\d{4})([xX\s]*(?<ext>\d+))?\s*\z/
      .match(number)
  end
end
