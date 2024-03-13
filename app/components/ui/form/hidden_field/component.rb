# frozen_string_literal: true

module UI
  module Form
    module HiddenField
      class Component < ApplicationViewComponent
        define_component_helper :hidden_field_component

        def initialize(name, value = nil, **options)
          @name = name
          @value = value
          @options = options
          super()
        end

        # FIXME: https://bugs.ruby-lang.org/issues/20090
        # Anonymous parameters & blocks cannot be forwarded within block in Ruby 3.3.0
        # May be fixed in Ruby 3.3.1
        #
        def each_field_value(name = @name, value = @value, &block)
          case value
          when Array
            value.each do |item|
              each_field_value("#{name}[]", item, &block)
            end
          when Hash
            value.each do |key, item|
              each_field_value("#{name}[#{key}]", item, &block)
            end
          else
            yield name, value, @options unless value.nil?
          end
        end
      end
    end
  end
end
