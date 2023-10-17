# frozen_string_literal: true

module UI
  class CopyableComponent < ApplicationViewComponent
    def initialize(value, secret: false)
      @value = value
      @secret = secret
      super()
    end
  end
end
