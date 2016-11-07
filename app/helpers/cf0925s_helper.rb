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
        f.text_field(:service_provider_name, column_width: 8, lstrip: '') +
          f.form_group(:payment,
                       label: { text: 'Payment to be provided to:' },
                       column_width: 4) do
            f.radio_button(:payment, 'provider', label: 'Service Provider') +
              f.radio_button(:payment, 'agency', label: 'Agency')
          end
      end
      a += content_tag(:div, class: 'row') do
        f.text_field(:agency_name, column_width: 8, label: 'Agency Name (if applicable)')
      end
      a += content_tag(:div, class: 'row') do
        f.text_field(:service_provider_address, column_width: 5, label: 'Address') +
          f.text_field(:service_provider_city, column_width: 3, label: 'City/Town') +
          f.text_field(:service_provider_postal_code, column_width: 2, label: 'Postal Code') +
          f.phone_field(:service_provider_phone,
                        column_width: 2,
                        label: 'Phone Number')
      end
      a += content_tag(:div, class: 'row') do
        f.text_field(:service_provider_service_1, column_width: 6) +
          f.date_field(:service_provider_service_start, column_width: 3, label: 'Start Date') +
          f.date_field(:service_provider_service_end, column_width: 3, label: 'End Date')
      end
      a += content_tag(:div, class: 'row') do
        f.text_field(:service_provider_service_2, column_width: 6) +
          f.text_field(:service_provider_service_fee, column_width: 2, label: 'Fee (incl PST)') +
          f.select(:service_provider_service_hour,
                   %w(Hour Day),
                   column_width: 2,
                   label: 'Per') +
          f.text_field(:service_provider_service_amount, column_width: 2, label: 'Total Amount')
      end
      a + content_tag(:div, class: 'row') do
        f.text_field(:service_provider_service_3, column_width: 6)
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
        f.supplier_field(:supplier_name,
                         column_width: 4,
                         label: 'Supplier Name') +
          f.supplier_field(:supplier_contact_person, column_width: 5) +
          f.phone_field(:supplier_phone,
                        column_width: 3,
                        label: 'Phone Number')
      end
      a += content_tag(:div, class: 'row') do
        f.supplier_field(:supplier_address, column_width: 6) +
          f.supplier_field(:supplier_city, column_width: 4) +
          f.supplier_field(:supplier_postal_code, column_width: 2)
      end
      a += content_tag(:div, class: 'row') do
        f.supplier_field(:item_desp_1, column_width: 6) +
          f.supplier_field(:item_cost_1, column_width: 2) +
          f.supplier_field(:item_total, column_width: 4)
      end
      a += content_tag(:div, class: 'row') do
        f.supplier_field(:item_desp_2, column_width: 6) +
          f.supplier_field(:item_cost_2, column_width: 2)
      end
      a + content_tag(:div, class: 'row') do
        f.supplier_field(:item_desp_3, column_width: 6) +
          f.supplier_field(:item_cost_3, column_width: 2)
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

  def wrap_field(width)
    content_tag :div, class: "col-md-#{width}" do
      yield
    end
  end

  def child_field(f, field, width = 4, opts = {}, &block)
    show_field(f, field, width, opts.merge(lstrip: 'Child'), &block)
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
