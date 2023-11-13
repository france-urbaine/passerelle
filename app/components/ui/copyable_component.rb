# frozen_string_literal: true

module UI
  class CopyableComponent < ApplicationViewComponent
    define_component_helper :copyable_component

    def initialize(value, secret: false)
      @value = value
      @secret = secret
      super()
    end
  end
end
