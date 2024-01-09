# frozen_string_literal: true

module UI
  module Button
    # @display frame "content"
    #
    class Preview < ApplicationViewComponentPreview
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

      # @!group With icon
      # --------------------------------------------------------------------------
      # @label With leading icon
      #
      def with_icon; end

      # @label With icon only (with accessibility issues)
      #
      def with_icon_only; end

      # @label With icon only, with accessibility cares
      #
      def with_icon_only_and_label; end

      # @label With more icon options (set, variant)
      #
      def with_icon_options; end
      #
      # @!endgroup

      # @!group Variants
      # --------------------------------------------------------------------------
      #
      # @label Default variants
      #
      def variants_colored; end

      # @label Default variants (disabled)
      #
      def variants_disabled; end

      # @label Discrete variants
      #
      def variants_discrete; end

      # @label Discrete variants (disabled)
      #
      def variants_discrete_disabled; end

      # @label With icon variants
      #
      def variants_with_icon; end

      # @label With icon variants (disabled)
      #
      def variants_with_icon_disabled; end

      # @label Icon only
      #
      def variants_icon_only; end

      # @label Icon only (disabled)
      #
      def variants_icon_only_disabled; end
      #
      # @!endgroup
    end
  end
end
