# frozen_string_literal: true

module Layout
  # @display frame false
  #
  class ContentFrameComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With asynchronous loading
    #
    def with_async_loading; end
  end
end
