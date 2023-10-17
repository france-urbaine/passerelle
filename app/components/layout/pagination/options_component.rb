# frozen_string_literal: true

module Layout
  module Pagination
    class OptionsComponent < ApplicationViewComponent
      attr_reader :pagy, :direction, :turbo_frame, :order_options

      def initialize(pagy, direction: "right", turbo_frame: "_top", order: {})
        @pagy          = pagy
        @direction     = direction
        @turbo_frame   = turbo_frame
        @order_options = order.stringify_keys
        super()
      end

      def order_url(key, direction = :asc)
        new_params = params.slice(:search).permit!
        new_params[:order] = direction == :asc ? key : "-#{key}"

        url_for(new_params)
      end

      def items_url(items)
        new_params = params.slice(:search, :order).permit!
        new_params[:items] = items

        url_for(new_params)
      end

      def order_button(name, key, direction)
        if direction == :asc
          label = "Trier par #{name}, par ordre croissant"
          icon  = "bars-arrow-up"
        else
          label = "Trier par #{name}, par ordre décroissant"
          icon  = "bars-arrow-down"
        end

        UI::ButtonComponent.new(
          label,
          order_url(key, direction),
          role:      "menuitem",
          icon:      icon,
          icon_only: true,
          data:      { turbo_frame: }
        )
      end

      def current_order_label
        label = order_options.fetch(current_order_key, "défaut")
        label += " (desc.)" if current_order_direction == :desc
        label
      end

      def current_order
        @current_order ||= params[:order].presence
      end

      def current_order_key
        @current_order_key ||= current_order&.slice(/^^-?(.+)$/, 1)
      end

      def current_order_direction
        @current_order_direction ||= current_order && (current_order[0] == "-" ? :desc : :asc)
      end
    end
  end
end
