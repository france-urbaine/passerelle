# frozen_string_literal: true

module UI
  module ContentFlow
    class TitleComponent < ApplicationViewComponent
      attr_reader :text, :icon, :icon_title

      def initialize(text, icon = nil, icon_title = nil)
        @text       = text
        @icon       = icon
        @icon_title = icon_title
        super()
      end
    end
  end
end
