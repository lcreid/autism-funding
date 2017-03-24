##
# Common methods for a preferences mechanism
module Preferences

  private

  def json(s)
    JSON.parse(s || '{}')
  end
end
