# frozen_string_literal: true

module Layout
  # @display frame "content"
  # @display width "small"
  #
  class SearchFormComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With a custom label
    #
    def with_label; end

    # @label With another URL
    #
    def with_url; end

    # @label With form targeting a turbo-frame
    #
    def with_turbo_frame; end
  end
end
