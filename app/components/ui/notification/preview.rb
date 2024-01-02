# frozen_string_literal: true

module UI
  module Notification
    # @display frame false
    #
    class Preview < ApplicationViewComponentPreview
      # @label Default
      #
      def default; end

      # @label With long text
      #
      def with_long_text; end

      # @label With custom icon
      #
      def with_custom_icon; end

      # @label With actions
      #
      def with_actions; end
    end
  end
end
