# frozen_string_literal: true

module TemplateContent
  # @logical_path Templating
  # @display frame false
  #
  class ComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With asynchronous loading
    #
    def with_async_loading; end
  end
end
