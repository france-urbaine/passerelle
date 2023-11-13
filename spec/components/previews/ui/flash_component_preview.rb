# frozen_string_literal: true

module UI
  # @display frame "content"
  #
  class FlashComponentPreview < ViewComponent::Preview
    # @!group Default
    #
    # @label Default
    #
    def default; end

    # @label Warning
    #
    def warning; end

    # @label Danger
    #
    def danger; end

    # @label Success
    #
    def success; end
    #
    # @!endgroup
  end
end
