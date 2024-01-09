# frozen_string_literal: true

module UI
  module Copyable
    class Component < ApplicationViewComponent
      define_component_helper :copyable_component

      def initialize(value, secret: false)
        @value = value
        @secret = secret
        super()
      end
    end
  end
end
