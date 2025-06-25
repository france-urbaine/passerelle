# frozen_string_literal: true

module Javascript
  # @display frame "content"
  class SwitchPreview < Lookbook::Preview
    # @!group Default
    def default; end
    def on_fieldsets; end
    # @!endgroup

    def other_visibility_options; end

    # @!group With multiple values
    def with_a_separator; end
    def with_an_array; end
    # @!endgroup

    def with_checkboxes; end
    def with_multiple_inputs; end
  end
end
