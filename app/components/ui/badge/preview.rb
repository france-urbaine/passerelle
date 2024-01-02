# frozen_string_literal: true

module UI
  module Badge
    # @display frame "content"
    # @display width "small"
    #
    class Preview < ApplicationViewComponentPreview
      # @label Default
      #
      def default; end

      # @label All colors
      #
      def all_colors; end

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
