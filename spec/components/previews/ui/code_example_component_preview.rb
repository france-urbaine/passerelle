# frozen_string_literal: true

module UI
  # @display frame "content"
  #
  class CodeExampleComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With command lines
    #
    def with_command_lines; end

    # @label With multiple languages
    #
    def with_multiple_languages; end

    # @label Inside other elements
    #
    def inside_card; end
  end
end
