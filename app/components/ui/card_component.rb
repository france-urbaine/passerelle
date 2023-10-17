# frozen_string_literal: true

module UI
  class CardComponent < ApplicationViewComponent
    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"

    renders_one :form, lambda { |**options, &block|
      self.form_options = options

      # `form_with` & `fields` have a similar API, but not quite:
      # * scope is passed as an option to `form_with``
      # * scope is passed as an argument to `fields`
      #
      scope = options[:scope]
      fields(scope, **options, &block)
    }

    renders_one  :submit_action, "SubmitAction"
    renders_many :actions, "Action"
    renders_one :raw_actions

    renders_many :multiparts, ->(**options) { Multipart.new(**@options, **options) }

    attr_accessor :form_options

    def initialize(**options)
      @options = options
      super()
    end

    DEFAULT_CSS_CLASSES = {
      class:         "card",
      content_class: "card__content",
      body_class:    "card__body",
      actions_class: "card__actions"
    }.freeze

    def css_classes(key)
      values = @options.fetch(key, [])
      values = Array.wrap(values)
      values << DEFAULT_CSS_CLASSES[key]
      values.compact.join(" ")
    end

    # Slots
    # --------------------------------------------------------------------------
    class SubmitAction < UI::ButtonComponent
      def initialize(*args, **options)
        super(*args, **options, primary: true, type: "submit")
      end
    end

    class Action < UI::ButtonComponent
    end

    class Multipart < self
    end
  end
end
