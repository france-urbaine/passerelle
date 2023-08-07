# frozen_string_literal: true

module FormBlock
  # @logical_path Interactive elements
  #
  # @display frame "content"
  # @display width "medium"
  #
  class ComponentPreview < ViewComponent::Preview
    # @label Text inputs
    # @display width "small"
    #
    def text_inputs; end

    # --------------------------------------------------------------------------

    # @label Selectors
    # @display width "small"
    #
    def selectors; end

    # --------------------------------------------------------------------------

    # @!group Check boxes
    # @display width "small"
    #
    # @label Single checkbox
    #
    def check_box; end

    # @label Multiple checkboxes
    #
    def check_boxes; end
    #
    # @!endgroup

    # --------------------------------------------------------------------------

    # @!group Radio buttons
    # @display width "small"
    #
    # @label Single radio buttons
    #
    def radio_button; end

    # @label Multiple radio buttons
    #
    def radio_buttons; end
    #
    # @!endgroup

    # --------------------------------------------------------------------------

    # @!group Input messages
    #
    # @label Text field with hint message
    #
    def text_field_with_hint; end

    # @label Text field with error message
    #
    def text_field_with_errors; end

    # @label Text field with validation errors
    #
    def text_field_with_validation_errors; end

    # @label Text field with all type of messages
    #
    def text_field_with_messages; end

    # @label Checkbox with hint message
    #
    def check_box_with_hint; end
    #
    # @!endgroup

    # --------------------------------------------------------------------------

    # @label Autocompletion
    #
    def autocompletion; end

    # --------------------------------------------------------------------------

    # @label Content switcher
    #
    def content_switcher; end
  end
end
