# frozen_string_literal: true

module UI
  class BadgeComponent < ApplicationViewComponent
    define_component_helper :badge_component

    SCHEME_CSS_CLASSES = {
      default:   "",
      warning:   "badge--warning",
      danger:    "badge--danger",
      success:   "badge--success",
      done:      "badge--done"
    }.freeze

    def initialize(label, scheme = :default, **html_attributes)
      @label           = label
      @scheme          = scheme
      @html_attributes = html_attributes

      validate_arguments!
      super()
    end

    def validate_arguments!
      raise ArgumentError, "unexpected scheme: #{@scheme.inspect}" unless SCHEME_CSS_CLASSES.include?(@scheme)
    end

    def call
      css_class = %w[badge]
      css_class << SCHEME_CSS_CLASSES[@scheme]
      css_class << @html_attributes[:class]
      css_class = css_class.join(" ").squish

      tag.div(@label, **@html_attributes, class: css_class)
    end
  end
end
