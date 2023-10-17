# frozen_string_literal: true

module UI
  # @display frame "content"
  #
  class IconComponentPreview < ViewComponent::Preview
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

    # @label Heroicon set
    #
    def with_heroicon_outline_set; end

    # @label Heroicon set (solid)
    #
    def with_heroicon_solid_set; end
    #
    # @!endgroup
  end
end
