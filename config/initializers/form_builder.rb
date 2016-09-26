module ActionView
  module Helpers
    ##
    # Add a method to FormBuilder to set up an error field for an input field.
    class FormBuilder
      ##
      # Create a place to put error messages for a field.
      def error_message_for(field_name)
        # puts "Message?: #{field_name}: #{object.errors[field_name]}"
        if object.errors[field_name].present?
          # puts "User prompted for: #{field_name}: #{object.errors[field_name].map(&:humanize)}"
          model_name = object.class.name.downcase
          id_of_element           = "error_#{model_name}_#{field_name}"
          target_elem_id          = "#{model_name}_#{field_name}"
          class_name              = 'signup-error alert alert-danger'
          # error_declaration_class = 'has-signup-error'

          @template.content_tag :div,
                                id: id_of_element,
                                for: target_elem_id,
                                class: class_name do
            object
              .errors[field_name]
              .map { |x| [field_name, x].join(' ').humanize }
              .join(', ')
          end
          # '<!-- Later JavaScript to add class to the parent element -->'\
          # '<script>'\
          #     'document.onreadystatechange = function(){'\
          #       "$('##{id_of_element}').parent()"\
          #       ".addClass('#{error_declaration_class}');"\
          #     '}'\
          # '</script>'.html_safe
        end
      end
    end
  end
end
