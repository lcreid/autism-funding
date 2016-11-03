module Formatters
  ##
  # Return the match if the input looks like it could be a Canadian postal
  # code. The match has the first three characters in return_value[:fsa],
  # and the last three characters in return_value[:ldu]
  def formatted_postal_code?(postal_code)
    /\A\s*(?<fsa>[a-zA-Z]\d[a-zA-Z])\s*(?<ldu>\d[a-zA-Z]\d)\s*\z/
      .match(postal_code)
  end

  ##
  # If the input string looks like a Canadian postal code, format it the
  # official way. Otherwise, leave it untouched.
  def format_postal_code(postal_code)
    match = formatted_postal_code?(postal_code)

    if match
      match[:fsa] + ' ' + match[:ldu]
    else
      postal_code
    end
  end
end
