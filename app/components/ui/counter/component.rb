# frozen_string_literal: true

module UI
  module Counter
    class Component < ApplicationViewComponent
      define_component_helper :counter_component

      def initialize(count)
        @count = count
        super()
      end

      def call
        return unless @count&.positive?

        tag.div(class: "counter") do
          case @count
          when 0..99 then @count.to_s
          else "99+"
          end
        end
      end
    end
  end
end
