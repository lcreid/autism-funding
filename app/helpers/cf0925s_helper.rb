module Cf0925sHelper
  def show_field(field, width = 4)
    wrap_field(width) do
      content_tag(:small, field.to_s.titlecase) +
        content_tag(:br) +
        content_tag(:span, @cf0925.send(field), id: field, class: 'value')
    end
  end

  def form_row(&block)
    raise ArgumentError, 'Missing block' unless block_given?
    content_tag :div, class: 'row' do
      capture(&block)
    end
  end

  def form_field(f, field, width = 4, &block)
    wrap_field(width) do
      if block_given?
        capture(&block)
      else
        f.label(field, class: 'hide-label') +
          f.text_field(field, placeholder: field)
      end
    end
  end

  def wrap_field(width)
    content_tag :div, class: "col-md-#{width}" do
      yield
    end
  end

  def wrap_date_field(f, field, width)
    wrap_field(width) do
      f.date_field(field)
    end
  end
end
