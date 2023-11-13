# frozen_string_literal: true

module Layout
  class ModalFrameComponent < ApplicationViewComponent
    define_component_helper :modal_frame_component

    renders_one :modal, -> { UI::ModalComponent.new(referrer: @referrer) }

    def initialize(referrer: nil)
      @referrer = referrer
      super()
    end
  end
end
