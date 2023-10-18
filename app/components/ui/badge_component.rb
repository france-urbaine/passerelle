# frozen_string_literal: true

module UI
  class BadgeComponent < ApplicationViewComponent
    # Colors are listed instead of being interpolated to be
    # be compiled by tailwind.
    #
    # Only few colors are pre-compiled.
    # If you need need another color, you need to pass the CSS class:
    # Ex:
    #   class: "badge--purple"
    #
    COLORS = {
      yellow:  "badge--yellow",
      orange:  "badge--orange",
      red:     "badge--red",
      blue:    "badge--blue",
      green:   "badge--green"
    }.freeze

    def initialize(label, color = nil, **options)
      @label   = label
      @color   = color
      @options = options
      super()
    end

    def call
      css_class = Array.wrap(@options[:class])
      css_class.unshift("badge")
      css_class.unshift(COLORS[@color]) if COLORS.include?(@color)

      tag.div(@label, **@options, class: css_class.join(" "))
    end
  end
end
