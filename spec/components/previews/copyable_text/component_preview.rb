# frozen_string_literal: true

module CopyableText
  # @logical_path Interactive elements
  #
  # @display frame "content"
  # @display width "medium"
  #
  class ComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With secret
    #
    def with_secret; end

    # @!group Inside other elements
    #
    # @label Inside a table
    #
    def inside_table; end

    # @label Inside a description list
    #
    def inside_description_list; end
    #
    # @!endgroup
  end
end
