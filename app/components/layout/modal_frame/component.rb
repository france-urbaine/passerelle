# frozen_string_literal: true

module Layout
  module ModalFrame
    class Component < ApplicationViewComponent
      renders_one :modal, -> { UI::Modal::Component.new(referrer: @referrer) }

      def initialize(referrer: nil)
        @referrer = referrer
        super()
      end
    end
  end
end
