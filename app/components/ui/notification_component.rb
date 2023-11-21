# frozen_string_literal: true

module UI
  class NotificationComponent < ApplicationViewComponent
    define_component_helper :notification_component

    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"
    renders_many :actions, "GenericAction"

    SCHEME_CSS_CLASSES = {
      default: "",
      warning: "notification--warning",
      danger:  "notification--danger",
      success: "notification--success",
      done:    "notification--done"
    }.freeze

    SCHEME_ICONS = {
      default: "information-circle",
      warning: "exclamation-triangle",
      danger:  "exclamation-triangle",
      success: "check-circle",
      done:    "check-circle"
    }.freeze

    attr_reader :delay

    def initialize(scheme = :default, delay: nil, icon: nil, icon_options: {})
      @scheme       = scheme
      @delay        = delay
      @icon         = icon
      @icon_options = icon_options

      validate_arguments!
      super()
    end

    def validate_arguments!
      raise ArgumentError, "unexpected scheme: #{@scheme.inspect}" unless SCHEME_CSS_CLASSES.include?(@scheme)
    end

    def scheme_css_class
      SCHEME_CSS_CLASSES[@scheme]
    end

    def icon
      icon         = @icon || SCHEME_ICONS[@scheme]
      icon_options = @icon_options || {}

      icon_component(icon, **icon_options)
    end
  end
end
