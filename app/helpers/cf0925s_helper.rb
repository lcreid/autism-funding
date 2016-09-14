module Cf0925sHelper
  def show_field(field, width = 4, opts = {}, &block)
    wrap_field(width) do
      content_tag(:small, format_label(field, opts)) +
        content_tag(:br) +
        if block_given?
          capture(&block)
        else
          content_tag(:span, @cf0925.send(field), id: field, class: 'value')
        end
    end
  end

  def form_row(&block)
    raise ArgumentError, 'Missing block' unless block_given?
    content_tag :div, class: 'row' do
      capture(&block)
    end
  end

  def form_field(f, field, width = 4, opts = {}, &block)
    wrap_field(width) do
      if block_given?
        a = capture(&block)
        a.prepend(content_tag(:small, format_label(field, opts)) +
                  content_tag(:br)) if field
        a
      else
        f.label(field, class: 'hide-label') +
          f.text_field(field, placeholder: format_label(field, opts))
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

  def child_field(_f, field, width = 4, &block)
    show_field(field, width, lstrip: 'Child', &block)
  end

  def parent_field(f, field, width = 4, &block)
    form_field(f, field, width, lstrip: 'Parent', &block)
  end

  def parent_phone_field(f, field, phone_number, _width = 3)
    f.fields_for :phone_number, phone_number do |phone|
      render partial: 'phone_numbers/form',
             locals: { f: f, type: field, phone_number: phone }
    end
  end

  def service_provider_field(f, field, width = 4, opts = {}, &block)
    form_field(f, field, width, { lstrip: 'Service Provider' }.merge(opts), &block)
  end

  def supplier_field(f, field, width = 4, opts = {}, &block)
    form_field(f, field, width, { lstrip: 'Supplier' }.merge(opts), &block)
  end

  def format_label(field, opts = {})
    label = field.class == String ? field : field.to_s.titlecase
    label = label.sub(/\A#{opts[:lstrip]}\s*/, '') if opts[:lstrip]
    label
  end

  def print_button(cf0925)
    if cf0925.printable?
      link_to 'Print',
              cf0925_path(cf0925, :pdf),
              class: 'btn'
    else
      content_tag :span, 'Print', class: 'btn'
    end
  end
end
