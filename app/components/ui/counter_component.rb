# frozen_string_literal: true

module UI
  class CounterComponent < ApplicationViewComponent
    def initialize(count)
      @count = count
      super()
    end

    def call
      return unless @count&.positive?

      tag.div(class: "counter-badge") do
        case @count
        when 0..99 then @count.to_s
        else "99+"
        end
      end
    end
  end
end
