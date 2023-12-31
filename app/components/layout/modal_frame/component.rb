# frozen_string_literal: true

module Layout
  module ModalFrame
    class Component < ApplicationViewComponent
      define_component_helper :modal_frame_component

      renders_one :modal, -> { UI::Modal::Component.new(referrer: @referrer) }

      def initialize(referrer: nil)
        @referrer = referrer
        super()
      end
    end
  end
end
