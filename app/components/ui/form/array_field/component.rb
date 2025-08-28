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

        def button_label
          @options[:button_label] || "Ajouter"
        end

        def input_html_attributes
          options = @options.dup

          options[:class] = "#{options[:class] || ''} mb-2"
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
