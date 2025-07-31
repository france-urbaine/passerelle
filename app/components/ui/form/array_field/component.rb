# frozen_string_literal: true

module UI
  module Form
    module ArrayField
      class Component < ApplicationViewComponent
        define_component_helper :array_field_component

        def initialize(object_name, method, values = [], **options)
          @object_name = object_name
          @method      = method
          @values      = values
          @options     = options
          super()
        end

        def input_html_attributes
          options = @options.dup

          options[:class] = "#{options[:class] || ''} mb-2"
          options[:data] ||= { action: "change->array-field#removeEmptyInput array-field#addEmptyInput" }
          options
        end

        def wrapper_html_attributes
          {
            data: { controller: "array-field" }
          }
        end
      end
    end
  end
end
