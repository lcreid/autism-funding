require 'autism_funding_form_builder'
##
# Field helpers for BC request to pay forms.
module Cf0925sHelper
  # Using bootstrap_form gem
  ##
  # The buttons at the bottom of the form.
  def buttons(f, cf0925)
    # content_tag :div, class: 'form-inline' do
    f.submit('Save', class: 'btn btn-primary') +
      print_button(cf0925) +
      home_button
    # end
  end

  ##
  # Form for completing the BC request to pay form (CF0925)
  def cf0925_form(funded_person, cf0925)
    bootstrap_form_for([funded_person, cf0925],
                       builder: AutismFundingFormBuilder) do |f|
      f.fields_for(:funded_person_attributes,
                   @cf0925.funded_person) do |child|
        child.hidden_field(:id) +
          child.fields_for(:user_attributes,
                           @cf0925.funded_person.user) do |parent|
            parent.hidden_field(:id) +
              parent_info(f, parent) +
              child_info(f) +
              part_A(f) +
              part_B(f) +
              buttons(f, cf0925)
          end
      end
    end
  end

  ##
  # Format view for child's info on the BC request to pay form (CF0925)
  def child_info(f)
    panel(f, 'Section 2 Child Information') do
      render partial: 'child_info', locals: { f: f }
    end
  end

  ##
  # Format view for parent's info on the BC request to pay form (CF0925)
  def parent_info(f, parent)
    panel(f, 'Section 1 Parent/Guardian Information') do
      # parent and form needed below just during refactoring.
      render partial: 'parent_info', locals: { parent: parent, form: f }
    end
  end

  ##
  # Format view for part A of the BC request to pay form (CF0925)
  def part_A(f)
    panel(f, 'Part A Services') do
      a = content_tag :p, 'Complete this section ' \
          'to authorize payment ' \
          'to a service provider ' \
          'who is providing autism intervention ' \
          'for the child.'

      a += content_tag(:div, class: 'row') do
        service_provider_field(f, :service_provider_name, 8, lstrip: '') +
          wrap_field(4) do
            f.form_group(:payment,
                         label: { text: 'Payment to be provided to:' }) do
              f.radio_button(:payment, 'provider', label: 'Service Provider') +
                f.radio_button(:payment, 'agency', label: 'Agency')
            end
          end
      end
      a += content_tag(:div, class: 'row') do
        service_provider_field(f, :agency_name, 8, label: 'Agency Name (if applicable)')
      end
      a += content_tag(:div, class: 'row') do
        service_provider_field(f, :service_provider_address, 5, label: 'Address') +
          service_provider_field(f, :service_provider_city, 3, label: 'City/Town') +
          service_provider_field(f, :service_provider_postal_code, 2, label: 'Postal Code') +
          wrap_in_column(2,
                         f.phone_field(:service_provider_phone,
                                       label: 'Phone Number'))
      end
      a += content_tag(:div, class: 'row') do
        service_provider_field(f, :service_provider_service_1, 6) +
          wrap_date_field(f, :service_provider_service_start, 3, label: 'Start Date') +
          wrap_date_field(f, :service_provider_service_end, 3, label: 'End Date')
      end
      a += content_tag(:div, class: 'row') do
        service_provider_field(f, :service_provider_service_2, 6) +
          service_provider_field(f, :service_provider_service_fee, 2, label: 'Fee (incl PST)') +
          # service_provider_field(f, :service_provider_service_hour, 2, label: 'Per') +
          wrap_field(2) do
            f.select(:service_provider_service_hour,
                     %w(Hour Day),
                     label: 'Per')
          end +
          service_provider_field(f, :service_provider_service_amount, 2, label: 'Total Amount')
      end
      a + content_tag(:div, class: 'row') do
        service_provider_field(f, :service_provider_service_3, 6)
      end
    end
  end

  ##
  # Format view for part B of the BC request to pay form (CF0925)
  def part_B(f)
    panel(f,
          'Part B Additional Expenses: '.html_safe +
            content_tag(:small, 'Travel, Training, Equipment, and Supplies')) do
      a = content_tag :p, 'Complete this section ' \
        'to authorize payment ' \
        'to a supplier ' \
        'for expenses related to travel, ' \
        'training, ' \
        'equipment ' \
        'or materials ' \
        'directly on behalf of a parent or guardian.'

      a += content_tag(:div, class: 'row') do
        wrap_in_column(4, f.supplier_field(:supplier_name, label: 'Supplier Name')) +
          wrap_in_column(5, f.supplier_field(:supplier_contact_person)) +
          wrap_in_column(3,
                         f.phone_field(:supplier_phone,
                                       label: 'Phone Number'))
      end
      a += content_tag(:div, class: 'row') do
        wrap_in_column(6, f.supplier_field(:supplier_address)) +
          wrap_in_column(4, f.supplier_field(:supplier_city)) +
          wrap_in_column(2, f.supplier_field(:supplier_postal_code))
      end
      a += content_tag(:div, class: 'row') do
        wrap_in_column(6, f.supplier_field(:item_desp_1)) +
          wrap_in_column(2, f.supplier_field(:item_cost_1)) +
          wrap_in_column(4, f.supplier_field(:item_total))
      end
      a += content_tag(:div, class: 'row') do
        wrap_in_column(6, f.supplier_field(:item_desp_2)) +
          wrap_in_column(2, f.supplier_field(:item_cost_2))
      end
      a + content_tag(:div, class: 'row') do
        wrap_in_column(6, f.supplier_field(:item_desp_3)) +
          wrap_in_column(2, f.supplier_field(:item_cost_3))
      end
    end
  end

  def field_with_error_message(f, field, opts = {})
    f.text_field(field, label: format_label(field, opts)) +
      f.error_message_for(field)
  end

  def wrap_in_column(width, text)
    content_tag :div, class: "col-md-#{width}" do
      if block_given?
        yield
      else
        text
      end
    end
  end

  # Old way

  def show_field(f, field, width = 4, opts = {}, &block)
    wrap_field(width) do
      # content_tag(:small, format_label(field, opts)) +
      opts[:label] ||= format_label(field, opts)
      f.static_control(field, opts, &block)
      # content_tag(:span, @cf0925.send(field), id: field, class: 'value')
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
        # FIXME: if you give a block, the options are ignored.
        a = capture(&block)
      else
        opts[:label] ||= format_label(field)
        opts[:placeholder] ||= opts[:label]
        a = f.text_field(field, opts)
      end
      # puts "about to add error message for #{field}..."
      # a + f.error_message_for(field)
    end
  end

  def wrap_field(width)
    content_tag :div, class: "col-md-#{width}" do
      yield
    end
  end

  def wrap_date_field(f, field, width, opts = {})
    wrap_field(width) do
      f.date_field(field, opts) #+
      # f.error_message_for(field)
    end
  end

  def child_field(f, field, width = 4, opts = {}, &block)
    show_field(f, field, width, opts.merge(lstrip: 'Child'), &block)
  end

  def parent_field(f, field, width = 4, opts = {}, &block)
    opts[:label] ||= format_label(field, lstrip: 'Parent')
    form_field(f, field, width, opts, &block)
  end

  def parent_phone_field(f, field, phone_number, _width = 3)
    f.fields_for :phone_number, phone_number do |phone|
      render partial: 'phone_numbers/form',
             locals: { f: f, type: field, phone_number: phone }
    end
  end

  def service_provider_field(f, field, width = 4, opts = {}, &block)
    opts[:label] ||= format_label(field, lstrip: 'Service Provider')
    form_field(f, field, width, opts, &block)
  end

  def format_label(field, opts = {})
    label = field.class == String ? field : field.to_s.titlecase
    label = label.sub(/\A#{opts[:lstrip]}\s*/, '') if opts[:lstrip]
    label
  end

  def print_button(cf0925, opts = {})
    cf0925_button(opts) do |classes|
      if cf0925.printable?
        link_to 'Print',
                cf0925_path(cf0925, :pdf),
                class: classes,
                target: '_blank'
      else
        content_tag :button, 'Print', class: classes + ' disabled'
      end
    end
  end

  def edit_button(cf0925, opts = {})
    cf0925_button(opts) do |classes|
      link_to 'Edit', edit_cf0925_path(cf0925), class: classes
    end
  end

  def home_button(opts = {})
    cf0925_button(opts) do |classes|
      link_to 'Home', home_index_path, class: classes
    end
  end

  def cf0925_button(opts)
    classes = 'btn btn-primary'
    classes += ' ' + opts[:class] if opts[:class]
    yield classes
  end

  private

  ##
  # Format a panel
  def panel(f, title, &block)
    content_tag :div, class: 'panel panel-primary' do
      a = content_tag(:div, class: 'panel-heading') do
        content_tag :h3, title, class: 'panel-title'
      end +
          content_tag(:div, class: 'panel-body') do
            capture(f, &block)
          end
    end
  end
end
