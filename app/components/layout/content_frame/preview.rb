# frozen_string_literal: true

module Layout
  module ContentFrame
    # @display frame false
    #
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
