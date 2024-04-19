# frozen_string_literal: true

module UI
  module Badge
    class Component < ApplicationViewComponent
      define_component_helper :badge_component

      SCHEME_CSS_CLASSES = {
        default:   "",
        warning:   "badge--warning",
        danger:    "badge--danger",
        success:   "badge--success",
        done:      "badge--done"
      }.freeze

      def initialize(label, scheme = :default, **)
        @label           = label
        @scheme          = scheme
        @html_attributes = parse_html_attributes(**)

        validate_arguments!
        super()
      end

      def validate_arguments!
        raise ArgumentError, "unexpected scheme: #{@scheme.inspect}" unless SCHEME_CSS_CLASSES.include?(@scheme)
      end

      def call
        tag.div(@label, **html_attributes)
      end

      def html_attributes
        attributes = {
          class: merge_class_attribute("badge", SCHEME_CSS_CLASSES[@scheme])
        }

        merge_attributes(attributes, @html_attributes)
      end
    end
  end
end
