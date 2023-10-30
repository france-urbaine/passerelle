# frozen_string_literal: true

module Layout
  class ModalFrameComponent < ApplicationViewComponent
    renders_one :modal, -> { UI::ModalComponent.new(referrer: @referrer) }

    def initialize(referrer: nil)
      @referrer = referrer
      super()
    end
  end
end
