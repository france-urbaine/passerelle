# frozen_string_literal: true

module UI
  module Datalist
    class Component < ApplicationViewComponent
      define_component_helper :datalist_component

      renders_many :options, "Option"

      def initialize(highlight: nil)
        @highlight = highlight
        super()
      end

      class Option < ContentSlot
        def initialize(*, value:, **)
          @value = value
          super
        end

        def value_to_attribute
          case @value
          when ActiveRecord::Base then @value.id
          when Hash               then @value.to_json
          else                         @value
          end
        end
      end
    end
  end
end
