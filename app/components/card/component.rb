# frozen_string_literal: true

module Card
  class Component < ApplicationViewComponent
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

    def css_classes(key)
      { class: Array.wrap(@options.fetch(key, [])) }
    end

    # Slots
    # --------------------------------------------------------------------------
    class SubmitAction < ::Button::Component
      def initialize(*args, **options)
        super(*args, **options, primary: true, type: "submit")
      end
    end

    class Action < ::Button::Component
    end

    class Multipart < self
    end
  end
end
