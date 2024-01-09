# frozen_string_literal: true

module UI
  module Flash
    # @display frame "content"
    #
    class Preview < ApplicationViewComponentPreview
      # @!group Default
      #
      # @label Default
      #
      def default; end

      # @label Warning scheme
      #
      def warning; end

      # @label Danger scheme
      #
      def danger; end

      # @label Success scheme
      #
      def success; end

      # @label Done scheme
      #
      def done; end
      #
      # @!endgroup

      # @label With custom icon
      #
      def with_custom_icon; end
    end
  end
end
