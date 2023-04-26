# frozen_string_literal: true

module Search
  class ComponentPreview < ApplicationViewComponentPreview
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
