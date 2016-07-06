module Cf0925sHelper
  def show_field(field, width = 4)
    "<div id=\"#{field}\" class=\".col-md-#{width}\">" \
      "#{field.to_s.titlecase}: " \
      "<span class=\"value\">#{@cf0925.send(field)}</span>" \
    '</div>'
      .html_safe
  end

  def form_row
    '<div class="row">'.html_safe
    yield
    '</div>'.html_safe
  end

  def form_field(field, width = 4)
    show_field(field, width)
  end
end
