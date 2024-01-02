# frozen_string_literal: true

module UI
  module Copyable
    # @display frame "content"
    # @display width "medium"
    #
    class Preview < ApplicationViewComponentPreview
      # @label Default
      #
      def default; end

      # @label With secret
      #
      def with_secret; end

      # @!group Inside other elements
      #
      # @label Inside a description list
      #
      def inside_description_list; end

      # @label Inside a table
      #
      def inside_table; end
      #
      # @!endgroup
    end
  end
end
