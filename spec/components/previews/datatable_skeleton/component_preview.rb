# frozen_string_literal: true

module DatatableSkeleton
  # @logical_path Layout components
  # @display frame "content"
  #
  class ComponentPreview < ViewComponent::Preview
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
