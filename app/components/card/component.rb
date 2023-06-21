# frozen_string_literal: true

module Card
  class Component < ApplicationViewComponent
    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"

    renders_one :form, lambda { |**options, &block|
      self.form_options = options
      fields(**options, &block)
    }

    renders_one  :submit_action, "SubmitAction"
    renders_many :actions, "Action"

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
  end
end
