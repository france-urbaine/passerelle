# frozen_string_literal: true

module Notification
  # @logical_path Layout components
  # @display frame false
  #
  class ComponentPreview < ViewComponent::Preview
    DEFAULT_TITLE = "Hello world !"
    DEFAULT_DESCRIPTION = <<~MESSAGE
      Lorem ipsum dolor sit amet, consectetur adipiscing elit.
      Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
    MESSAGE

    # @label Default
    #
    def default; end

    # @label With types
    #
    def with_types; end

    # @label With description
    # @param title text
    # @param description textarea
    #
    def with_description(title: DEFAULT_TITLE, description: DEFAULT_DESCRIPTION)
      render_with_template(locals: { title:, description: })
    end

    # @label With actions
    #
    def with_actions(title: DEFAULT_TITLE, description: DEFAULT_DESCRIPTION)
      render_with_template(locals: { title:, description: })
    end
  end
end
