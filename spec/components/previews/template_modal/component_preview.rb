# frozen_string_literal: true

module TemplateModal
  # @logical_path Templating
  # @display frame false
  #
  class ComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With asynchronous background
    #
    def with_async_background; end

    # @label With explicit modal content
    #
    def with_explicit_modal; end
  end
end
