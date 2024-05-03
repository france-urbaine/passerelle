# frozen_string_literal: true

module UI
  module Card
    class Component < ApplicationViewComponent
      define_component_helper :card_component

      renders_one :header, "ContentSlot"
      renders_one :body, "ContentSlot"

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
      renders_many :actions, "ActionSlot"
      renders_many :multiparts, "Multipart"

      attr_accessor :form_options

      def initialize(**)
        @html_attributes = parse_html_attributes(**)
        super()
      end

      # Slots
      # --------------------------------------------------------------------------
      class SubmitAction < UI::Button::Component
        def initialize(*args, **options)
          super(*args, **options, primary: true, type: "submit")
        end
      end

      class Multipart < self
      end
    end
  end
end
