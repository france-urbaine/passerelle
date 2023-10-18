# frozen_string_literal: true

module Layout
  module Datatable
    # @display frame "content"
    #
    class SkeletonComponentPreview < ViewComponent::Preview
      # @label Default
      #
      def default; end

      # @label With options
      #
      def with_options; end

      # @label With header bar
      #
      def with_header_bar; end
    end
  end
end
