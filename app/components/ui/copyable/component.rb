# frozen_string_literal: true

module UI
  module Copyable
    class Component < ApplicationViewComponent
      def initialize(value, secret: false)
        @value = value
        @secret = secret
        super()
      end
    end
  end
end
