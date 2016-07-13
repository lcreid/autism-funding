module Cf0925sHelper
  def show_field(field, width = 4)
    wrap_field(width) do
      "<small>#{field.to_s.titlecase}</small><br/>" \
      "<span id=\"#{field}\" class=\"value\">#{@cf0925.send(field)}</span>"
    end
  end

  def form_row(&block)
    raise ArgumentError, 'Missing block' unless block_given?
    ('<div class="row">' +
      capture(&block) +
      '</div>').html_safe
  end

  def form_field(f, field, width = 4, &block)
    wrap_field(width) do
      if block_given?
        capture(&block)
      else
        f.text_field field, placeholder: field
      end
    end
  end

  def wrap_field(width)
    ("<div class=\"col-md-#{width}\">" +
      yield +
      '</div>').html_safe
  end
end
