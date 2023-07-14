# frozen_string_literal: true

module HiddenField
  class Component < ApplicationViewComponent
    def initialize(name, value = nil, **options)
      @name = name
      @value = value
      @options = options
      super()
    end

    def each_field_value(name = @name, value = @value, &)
      case value
      when Array
        value.each do |item|
          each_field_value("#{name}[]", item, &)
        end
      when Hash
        value.each do |key, item|
          each_field_value("#{name}[#{key}]", item, &)
        end
      else
        yield name, value, @options unless value.nil?
      end
    end
  end
end
