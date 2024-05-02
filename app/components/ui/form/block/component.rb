# frozen_string_literal: true

module UI
  module Form
    module Block
      class Component < ApplicationViewComponent
        define_component_helper :form_block_component

        renders_many :errors
        renders_one :hint

        def initialize(record, attribute, autocomplete: false, **options)
          @record = record
          @attribute = attribute
          @autocomplete = autocomplete
          @options = options
          super()
        end

        def block_html_attributes
          options = @options.dup

          options[:data] ||= {}
          options[:class] ||= ""

          options[:class] += " form-block"
          options[:class] += " form-block--invalid" if invalid? || errors?

          if @autocomplete
            options[:class] += " hidden autocomplete"
            options[:data][:controller] = "autocomplete"
            options[:data][:autocomplete_url_value] = @autocomplete
            options[:data][:autocomplete_selected_class] = "autocomplete__list-item--active"
          end

          options
        end

        def invalid?
          @record.respond_to?(:errors) && @record.errors.include?(@attribute)
        end
      end
    end
  end
end
