# frozen_string_literal: true

module UI
  class FlashComponent < ApplicationViewComponent
    define_component_helper :flash_component

    SHEMES_CSS = {
      default: "",
      warning: "flash--warning",
      danger:  "flash--danger",
      success: "flash--success"
    }.freeze

    def initialize(scheme = :default)
      raise ArgumentError, "unexpected scheme: #{scheme}" unless SHEMES_CSS.include?(scheme)

      @scheme = scheme
      super()
    end

    def scheme_css_class
      SHEMES_CSS[@scheme]
    end
  end
end
