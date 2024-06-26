# frozen_string_literal: true

module UI
  module Modal
    class Component < ApplicationViewComponent
      define_component_helper :modal_component

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
      renders_one  :close_action, lambda { |*args, **options|
        CloseAction.new(*args, **options, href: referrer)
      }

      renders_many :actions, "ActionSlot"
      renders_many :other_actions, "OtherAction"
      renders_one :raw_actions

      renders_many :hidden_fields, UI::Form::HiddenField::Component

      attr_reader :referrer
      attr_accessor :form_options

      def initialize(referrer: nil, **)
        @referrer        = referrer
        @html_attributes = parse_html_attributes(**)
        super(**)
      end

      def modal_attributes
        reverse_merge_attributes(@html_attributes, {
          class: "modal",
          role:  "dialog",
          aria: {
            modal:       true,
            labelledby:  (component_dom_id(:title) if header),
            describedby: component_dom_id(:body)
          },
          data: {
            controller:            "modal",
            action:                "keydown@document->modal#keydown",
            transition_enter_from: "modal--enter-from",
            transition_enter_to:   "modal--enter-to",
            transition_leave_from: "modal--leave-from",
            transition_leave_to:   "modal--leave-to"
          }
        })
      end

      protected

      def close_button
        helpers.button_component(
          icon: "x-mark",
          href: referrer,
          class: "modal__close-button",
          aria: { label: "Fermer la fenêtre de dialogue" },
          data: {
            turbo_frame: "content",
            action:      "click->modal#close"
          }
        )
      end

      # Slots
      # --------------------------------------------------------------------------
      class SubmitAction < UI::Button::Component
        def initialize(*args, **options)
          super(*args, **options, primary: true, type: "submit")
        end
      end

      class CloseAction < UI::Button::Component
        def initialize(*args, **options)
          options[:class] ||= ""
          options[:class] += " modal__close-action"

          options[:data] ||= {}
          options[:data][:turbo_frame] ||= "content"
          options[:data][:action]      ||= "click->modal#close"

          super(*args, **options)
        end
      end

      class OtherAction < UI::Button::Component
        def initialize(*args, **options)
          options[:class] ||= ""
          options[:class] += " modal__secondary-action"

          super(*args, **options)
        end
      end
    end
  end
end
