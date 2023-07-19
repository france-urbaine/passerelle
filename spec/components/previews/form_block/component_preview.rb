# frozen_string_literal: true

module FormBlock
  # @logical_path Interactive elements
  #
  # @display frame "content"
  # @display width "medium"
  #
  class ComponentPreview < ViewComponent::Preview
    # @!group Inputs
    # @display width "small"
    # --------------------------------------------------------------------------
    #
    # @label Text fields
    #
    def text_fields; end

    # @label Select options
    #
    def select; end

    # @label Checkbox
    #
    def check_box; end

    # @label Radio button
    #
    def radio_button; end
    #
    # @!endgroup

    # @!group Input messages
    # --------------------------------------------------------------------------
    #
    # @label Text field with hint message
    #
    def text_field_with_hint; end

    # @label Text field with error message
    def text_field_with_errors; end

    # @label Text field with hint & error message
    def text_field_with_hint_and_errors; end

    # @label Checkbox with hint message
    #
    def check_box_with_hint; end
    #
    # @!endgroup

    # @!group Autocompletion
    # --------------------------------------------------------------------------
    # @label Autocompletion field
    #
    def autocompletion; end
    #
    # @!endgroup
  end
end
