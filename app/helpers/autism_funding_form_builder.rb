##
# Subclass the We Enhance IT form builder for the autism funding application.
class AutismFundingFormBuilder < WeitFormBuilder
  # def bootstrap_form_for(object, options = {}, &block)
  #   super(object, options, &block)
  # end

  ##
  # Format the text field for the supplier into field
  def supplier_field(field, opts = {})
    opts[:label] ||= format_label(field, { lstrip: 'Supplier' }.merge(opts))
    opts[:placeholder] ||= opts[:label]
    # opts[:help] = 'Enter a supplier name.'
    text_field(field, opts) # + error_message_for(field)
  end

  private

  def format_label(field, opts = {})
    label = field.class == String ? field : field.to_s.titlecase
    label = label.sub(/\A#{opts[:lstrip]}\s*/, '') if opts[:lstrip]
    label
  end
end
