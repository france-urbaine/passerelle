# frozen_string_literal: true

module UI
  module Flash
    class Component < ApplicationViewComponent
      define_component_helper :flash_component

      SCHEME_CSS_CLASSES = {
        default: "",
        warning: "flash--warning",
        danger:  "flash--danger",
        success: "flash--success",
        done:    "flash--done"
      }.freeze

      SCHEME_ICONS = {
        default: "information-circle",
        warning: "exclamation-triangle",
        danger:  "exclamation-triangle",
        success: "check-circle",
        done:    "check-circle"
      }.freeze

      def initialize(scheme = :default, icon: nil, icon_options: {}, **html_attributes)
        @scheme          = scheme
        @icon            = icon
        @icon_options    = icon_options
        @html_attributes = html_attributes

        validate_arguments!
        super()
      end

      def validate_arguments!
        raise ArgumentError, "unexpected scheme: #{@scheme.inspect}" unless SCHEME_CSS_CLASSES.include?(@scheme)
      end

      def html_attributes
        css_class = %w[flash]
        css_class << SCHEME_CSS_CLASSES[@scheme]
        css_class << @html_attributes[:class]
        css_class = css_class.join(" ").squish

        @html_attributes.merge(class: css_class)
      end

      def icon
        icon         = @icon || SCHEME_ICONS[@scheme]
        icon_options = @icon_options || {}

        icon_component(icon, **icon_options)
      end
    end
  end
end
