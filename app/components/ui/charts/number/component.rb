# frozen_string_literal: true

module UI
  module Charts
    module Number
      class Component < ApplicationViewComponent
        define_component_helper :chart_number_component

        def initialize(number, singular, plural = nil)
          @number   = number
          @singular = singular
          @plural   = plural
          super()
        end
      end
    end
  end
end
