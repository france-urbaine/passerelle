# frozen_string_literal: true

module FormHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    def block(...)
      @template.form_block_component(@object, ...)
    end

    def errors(method)
      @template.display_errors(@object, method)
    end

    def password_field_component(...)
      @template.password_field_component(@object_name, ...)
    end

    def checkboxes_component(method, collection, **options)
      @template.checkboxes_component(@object_name, method, collection, **objectify_options(options))
    end

    def radio_buttons_component(method, collection, **options)
      @template.radio_buttons_component(@object_name, method, collection, **objectify_options(options))
    end
  end

  def hidden_param_input(key, &)
    render HiddenField::Component.new(key, params[key]) if params.key?(key)
  end

  def display_errors(record, attribute)
    return unless record.respond_to?(:errors)

    capture do
      record.errors.messages_for(attribute).each do |error|
        concat tag.div(error, class: "form-block__errors")
      end
    end
  end

  def autocomplete_results
    tag.div class: "autocomplete__list-wrapper" do
      tag.ul class: "autocomplete__list", data: { autocomplete_target: "results" }
    end
  end
end
