# frozen_string_literal: true

module Layout
  module ContentFrame
    class Component < ApplicationViewComponent
      def initialize(src: nil)
        @src = src
        super()
      end
    end
  end
end
