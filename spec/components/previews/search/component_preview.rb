# frozen_string_literal: true

module Search
  # @logical_path Interactive elements
  #
  # @display frame "content"
  # @display width "small"
  #
  class ComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With a custom label
    #
    def with_label; end

    # @label With form targeting a turbo-frame
    #
    def with_turbo_frame; end
  end
end
