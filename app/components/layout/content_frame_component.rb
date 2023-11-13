# frozen_string_literal: true

module Layout
  class ContentFrameComponent < ApplicationViewComponent
    define_component_helper :content_frame_component

    def initialize(src: nil)
      @src = src
      super()
    end
  end
end
