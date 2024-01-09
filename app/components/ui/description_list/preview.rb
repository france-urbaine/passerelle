# frozen_string_literal: true

module UI
  module DescriptionList
    # @display frame "content"
    #
    class Preview < ApplicationViewComponentPreview
      # @label Default
      #
      def default; end

      # @label With record
      #
      def with_record; end

      # @label With actions
      #
      def with_actions; end

      # @label With reference
      #
      def with_reference; end
    end
  end
end
