# frozen_string_literal: true

module Form
  # @logical_path Interactive elements
  # @display frame "content"
  #
  class ComponentPreview < ::Lookbook::Preview
    # @!group Inputs
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

    # @label Checkbox with hint message
    #
    def check_box_with_hint; end
    #
    # @!endgroup
  end
end
