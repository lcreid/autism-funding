module Cf0925sHelper
  def show_field(field)
    "<p id=\"#{field}\">#{field.to_s.titlecase}: " \
      "<span class=\"value\">#{@cf0925.send(field)}</span></p>"
      .html_safe
  end
end
