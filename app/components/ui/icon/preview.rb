# frozen_string_literal: true

module UI
  module Icon
    # @display frame "content"
    #
    class Preview < ApplicationViewComponentPreview
      # @label Default
      #
      def default; end

      # @label With ARIA title
      #
      def with_title; end

      # @!group Sets and variants
      #
      # About icons:
      # * Icons from Heroicons can be browsed at [https://heroicons.com/](https://heroicons.com/)
      # * Implemented variants are `outline` & `solid`
      #
      # @label From app/assets folder
      #
      def with_assets_set; end

      # @label Heroicon set (outline)
      #
      def with_heroicon_outline_set; end

      # @label Heroicon set (solid)
      #
      def with_heroicon_solid_set; end
      #
      # @!endgroup
    end
  end
end
