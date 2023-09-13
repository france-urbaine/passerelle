# frozen_string_literal: true

module FormBlock
  class Component < ApplicationViewComponent
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

    def display_errors
      helpers.display_errors(@record, @attribute) if invalid?
    end

    def invalid?
      @record.respond_to?(:errors) && @record.errors.include?(@attribute)
    end
  end
end
