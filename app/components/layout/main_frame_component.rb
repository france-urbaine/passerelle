# frozen_string_literal: true

module Layout
  class MainFrameComponent < ViewComponent::Base
    def initialize(src: nil)
      @src = src
      super()
    end
  end
end
