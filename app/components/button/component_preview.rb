# frozen_string_literal: true

module Button
  class ComponentPreview < ApplicationViewComponentPreview
    # @!group Default
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def default; end

    # @label Using block to capture label
    #
    def with_block; end

    # @label Button to open a link
    #
    def with_link; end

    # @label Button to open a link in a modal
    #
    def with_modal; end

    # @label Button to submit a link with a given method
    #
    def with_method; end

    # @label Primary button
    #
    def primary; end

    # @label Destructive button
    #
    def destructive; end
    #
    # @!endgroup

    # @!group With text and icon
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def with_icon; end

    # @label Primary button with text and icon
    #
    def primary_with_icon; end

    # @label Destructive button with text and icon
    #
    def destructive_with_icon; end

    # @label Disabled button
    #
    def disabled_with_icon; end

    # @label Primary button disabled
    #
    def primary_disabled_with_icon; end

    # @label Destructive button disabled
    #
    def destructive_disabled_with_icon; end
    #
    # @!endgroup

    # @!group With icon only
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def with_only_icon; end

    # @label With aria label and tooltip
    #
    def with_tooltip; end

    # @label Primary button with icon only
    #
    def primary_only_icon; end

    # @label Destructive button with icon icon only
    #
    def destructive_only_icon; end

    # @label Disabled button
    #
    def disabled_with_only_icon; end

    # @label Primary button disabled
    #
    def primary_disabled_only_icon; end

    # @label Destructive button disabled
    #
    def destructive_disabled_only_icon; end
    #
    # @!endgroup
  end
end
