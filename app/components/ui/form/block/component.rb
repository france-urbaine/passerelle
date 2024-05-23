# frozen_string_literal: true

module UI
  module Form
    module Block
      class Component < ApplicationViewComponent
        define_component_helper :form_block_component

        renders_many :errors
        renders_one  :hint

        def initialize(record, attribute, **)
          @record          = record
          @attribute       = attribute
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def block_html_attributes
          attributes = @html_attributes
          attributes = reverse_merge_attributes(attributes, { class: "form-block" })
          attributes = reverse_merge_attributes(attributes, { class: "form-block--invalid" }) if invalid? || errors?
          attributes
        end

        def invalid?
          @record.respond_to?(:errors) && @record.errors.include?(@attribute)
        end
      end
    end
  end
end
