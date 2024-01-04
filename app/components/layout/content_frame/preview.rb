# frozen_string_literal: true

module Layout
  # @display frame false
  #
  module ContentFrame
    class Preview < ApplicationViewComponentPreview
      # @label Default
      #
      def default; end

      # @label With asynchronous loading
      #
      def with_async_loading; end
    end
  end
end
