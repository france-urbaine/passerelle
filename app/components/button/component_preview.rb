# frozen_string_literal: true

module Button
  class ComponentPreview < ApplicationViewComponentPreview
    # @!group Default
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def default; end

    # @label Using a block to capture the label
    #
    def default_with_block; end

    # @label Button to open a link
    #
    def default_with_link; end

    # @label Button to open a link, using a block to capture the label
    #
    def default_with_link_and_block; end

    # @label Button to open a link in a modal
    #
    def default_with_modal; end

    # @label Button to submit a link with a given method
    #
    def default_with_method; end

    # @label Button to submit a link with a given method
    #
    def default_disabled; end

    # @!group Variants
    # --------------------------------------------------------------------------
    #
    # @label Colored buttons
    #
    def variants_colored; end

    # @label Colored buttons disabled
    #
    def variants_disabled; end

    # @label Discrete buttons
    #
    def variants_discrete; end

    # @label Discrete buttons disabled
    #
    def variants_discrete_disabled; end

    # @label With icons
    #
    def variants_with_icon; end

    # @label Disabled with icons
    #
    def variants_with_icon_disabled; end
    #
    # @!endgroup

    # @!group Icon only
    # --------------------------------------------------------------------------
    #
    # @label Default
    #
    def icon_only; end

    # @label With aria label and tooltip
    #
    def icon_only_with_label; end

    # @label Colored variants
    #
    def icon_only_colored; end

    # @label Disabled buttons
    #
    def icon_only_disabled; end
  end
end
