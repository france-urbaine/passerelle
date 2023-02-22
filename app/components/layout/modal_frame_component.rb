# frozen_string_literal: true

module Layout
  class ModalFrameComponent < ViewComponent::Base
    def initialize(src: nil)
      @src = src
      super()
    end

    def turbo_frame_request?
      request.headers["Turbo-Frame"].present?
    end
  end
end
