# frozen_string_literal: true

module Layout
  class ContentFrameComponent < ApplicationViewComponent
    def initialize(src: nil)
      @src = src
      super()
    end
  end
end
