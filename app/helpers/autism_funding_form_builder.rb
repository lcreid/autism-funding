##
# Subclass the We Enhance IT form builder for the autism funding application.
class AutismFundingFormBuilder < WeitFormBuilder
  # Find formatters.rb in app/lib
  include Formatters
  # def bootstrap_form_for(object, options = {}, &block)
  #   super(object, options, &block)
  # end

  ##
  # Format the text field for the supplier into field
  def supplier_field(field, options = {})
    options[:label] ||= format_label(field,
                                     { lstrip: 'Supplier' }.merge(options))
    options[:placeholder] ||= options[:label]
    # options[:help] = 'Enter a supplier name.'
    text_field(field, options) # + error_message_for(field)
  end

  ##
  # Format a phone number field and show it with punctuation
  def phone_field(method, options = {})
    options = process_options(method, options)
    options[:value] ||= @template.number_to_phone(object.send(method),
                                                  area_code: true)
    super
  end

  ##
  # Format a Canadian postal code field, or leave it untouched it if doesn't
  # look like a Canadian postal code
  def postal_code_field(method, options = {})
    options = process_options(method, options)
    options[:value] ||= format_postal_code(object.send(method))
    text_field(method, options)
  end

  private

  def format_label(field, options = {})
    label = field.class == String ? field : field.to_s.titlecase
    label = label.sub(/\A#{options[:lstrip]}\s*/, '') if options[:lstrip]
    label
  end

  def process_options(method, options)
    label_modifier = options.delete(:lstrip)
    options[:label] ||= format_label(method, label_modifier)
    options[:placeholder] ||= options[:label]
    options
  end
end
