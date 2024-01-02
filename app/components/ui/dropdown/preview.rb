# frozen_string_literal: true

module UI
  module Dropdown
    # @display frame "content"
    #
    class Preview < ApplicationViewComponentPreview
      # @label Default
      #
      def default; end

      # @label With an icon button
      #
      def with_icon_button; end

      # @!group With position and direction
      # --------------------------------------------------------------------------
      #
      # @label With menu below, direction right
      #
      def with_position_below_right; end

      # @label With menu aside, direction right
      #
      def with_position_aside_right; end

      # @label With menu below, direction left
      #
      def with_position_below_left; end

      # @label With menu aside, direction left
      #
      def with_position_aside_left; end
      #
      # @!endgroup

      # @!group With nested menus
      # --------------------------------------------------------------------------
      #
      # @label With nested menus, direction right
      #
      def with_nested_menus_right; end

      # @label With nested menus, direction left
      #
      def with_nested_menus_left; end
      #
      # @!endgroup

      # --------------------------------------------------------------------------
      # @label With custom menu items
      #
      def with_custom_items; end
      #
      # @!endgroup
    end
  end
end
