module Cf0925sHelper
  def show_field(field, width = 4)
    "<div id=\"#{field}\" class=\"col-md-#{width}\">" \
      "<small>#{field.to_s.titlecase}</small><br/>" \
      "<span class=\"value\">#{@cf0925.send(field)}</span>" \
    '</div>'
      .html_safe
  end

  def form_row(&block)
    raise ArgumentError, 'Missing block' unless block_given?
    ('<div class="row">' +
      capture(&block) +
      '</div>').html_safe
  end

  def form_field(field, width = 4)
    show_field(field, width)
  end
end
