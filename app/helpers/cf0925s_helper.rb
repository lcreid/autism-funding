require 'augmented_bootstrap_forms'
##
# Field helpers for BC request to pay forms.
module Cf0925sHelper
  # Using bootstrap_forms gem
  ##
  # The buttons at the bottom of the form.
  def buttons(f, cf0925)
    content_tag :div, class: "form-inline" do
      f.submit('Save', class: 'btn btn-primary') +
      print_button(cf0925) +
      home_button
    end
  end

  ##
  # Form for completing the BC request to pay form (CF0925)
  def cf0925_form(funded_person, cf0925)
    bootstrap_form_for([funded_person, cf0925],
                       builder: AugmentedBootstrapForms) do |f|
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
    panel(f, "Section 2 Child Information") do
      render partial: 'child_info', locals: { f: f }
    end
  end

  ##
  # Format view for parent's info on the BC request to pay form (CF0925)
  def parent_info(f, parent)
    panel(f, "Section 1 Parent/Guardian Information") do
      # parent and form needed below just during refactoring.
      render partial: 'parent_info', locals: { parent: parent, form: f }
    end
  end

  ##
  # Format view for part A of the BC request to pay form (CF0925)
  def part_A(f)
    panel(f, "Part A Services") do
      a = content_tag :p, "Complete this section " \
          "to authorize payment " \
          "to a service provider " \
          "who is providing autism intervention " \
          "for the child."

      a += content_tag(:div, class: 'form-inline') do
        service_provider_field(f, :service_provider_name, 8, lstrip: '') +
        service_provider_field(f, "Payment to be provided to:", 4) do
          f.radio_button(:payment, 'provider') +
          f.label('Service Provider') +
          "<br/>".html_safe +
          f.radio_button(:payment, 'agency') +
          f.label('Agency') +
          f.error_message_for(:payment)
        end
      end
      a += content_tag(:div, class: 'form-inline') do
        service_provider_field(f, :agency_name, 8)
      end
      a += content_tag(:div, class: 'form-inline') do
        service_provider_field(f, :service_provider_address, 5) +
          service_provider_field(f, :service_provider_city, 3) +
          service_provider_field(f, :service_provider_postal_code, 2) +
          service_provider_field(f, :service_provider_phone, 2)
      end
      a += content_tag(:div, class: 'form-inline') do
        service_provider_field(f, :service_provider_service_1, 6) +
          wrap_date_field(f, :service_provider_service_start, 3) +
          wrap_date_field(f, :service_provider_service_end, 3)
      end
      a += content_tag(:div, class: 'form-inline') do
        service_provider_field(f, :service_provider_service_2, 6) +
          service_provider_field(f, :service_provider_service_fee, 2) +
          service_provider_field(f, :service_provider_service_hour, 2) +
          service_provider_field(f, :service_provider_service_amount, 2)
      end
      a + content_tag(:div, class: 'form-inline') do
        service_provider_field(f, :service_provider_service_3, 6)
      end
    end
  end

  ##
  # Format view for part B of the BC request to pay form (CF0925)
  def part_B(f)
    panel(f,
          "Part B Additional Expenses: ".html_safe +
            content_tag(:small, "Travel, Training, Equipment, and Supplies")) do
      a = content_tag :p, "Complete this section " \
        "to authorize payment " \
        "to a supplier " \
        "for expenses related to travel, " \
        "training, " \
        "equipment " \
        "or materials " \
        "directly on behalf of a parent or guardian."

      a += content_tag(:div, class: 'form-inline') do
        wrap_in_column(4, f.supplier_field(:supplier_name, label: 'Supplier Name')) +
          wrap_in_column(5, f.supplier_field(:supplier_contact_person)) +
          wrap_in_column(3, f.supplier_field(:supplier_phone))
      end
      a += content_tag(:div, class: 'form-inline') do
        wrap_in_column(6, f.supplier_field(:supplier_address)) +
          wrap_in_column(4, f.supplier_field(:supplier_city)) +
          wrap_in_column(2, f.supplier_field(:supplier_postal_code))
      end
      a += content_tag(:div, class: 'form-inline') do
        wrap_in_column(6, f.supplier_field(:item_desp_1)) +
          wrap_in_column(2, f.supplier_field(:item_cost_1)) +
          wrap_in_column(4, f.supplier_field(:item_total))
      end
      a += content_tag(:div, class: 'form-inline') do
        wrap_in_column(6, f.supplier_field(:item_desp_2)) +
          wrap_in_column(2, f.supplier_field(:item_cost_2))
      end
      a + content_tag(:div, class: 'form-inline') do
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
    content_tag :div, class: 'form-inline' do
      capture(&block)
    end
  end

  def form_field(f, field, width = 4, opts = {}, &block)
    wrap_field(width) do
      if block_given?
        a = capture(&block)
        a.prepend(content_tag(:small, format_label(field, opts)) +
                  content_tag(:br)) if field
      else
        a = f.label(field, class: 'hide-label') +
            f.text_field(field, placeholder: format_label(field, opts))
      end
      # puts "about to add error message for #{field}..."
      a + f.error_message_for(field)
    end
  end

  def wrap_field(width)
    content_tag :div, class: "col-md-#{width}" do
      yield
    end
  end

  def wrap_date_field(f, field, width)
    wrap_field(width) do
      f.date_field(field) +
        f.error_message_for(field)
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
    content_tag :div, class: "panel panel-primary" do
      a = content_tag(:div, class: "panel-heading") do
        content_tag :h3, title, class: "panel-title"
      end +
      content_tag(:div, class: "panel-body") do
        capture(f, &block)
      end
    end
  end
end
