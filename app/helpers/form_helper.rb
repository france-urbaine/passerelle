# frozen_string_literal: true

module FormHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    def block(...)
      @template.form_block_component(@object, ...)
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
end
