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
        CloseAction.new(*args, **options, href: close_href)
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

      def close_href
        # If the modal is open through XHR, we don't need to put an URL in buttons
        # to close the modal: Javascript handled modal opening without changing
        # the current URL and would handle closing.
        #
        # If the modal has been opened from opening a link to a new window,
        # the current URL targets the current modal : no XHR involved.
        # In this case, we need to put an URL in closing buttons to force
        # redirections on closing.
        #
        # NOTE: After upgrading from Turbo 7 to 8, there is an issue
        # after closing the model and using back button:

        referrer if referrer && !turbo_frame_request?
      end

      def close_button
        helpers.button_component "Fermer la fenêtre de dialogue", close_href,
          icon:      "x-mark",
          icon_only: true,
          class:     "modal__close-button",
          data:      {
            turbo_frame:    "content",
            action:         "click->modal#close"
          }
      end

      # Slots
      # --------------------------------------------------------------------------
      class SubmitAction < UI::Button::Component
        def initialize(*, **)
          super(*, **, primary: true, type: "submit")
        end
      end

      class CloseAction < UI::Button::Component
        def initialize(*, **options)
          options = merge_attributes(options, {
            class: "modal__close-action",
            data:  {
              turbo_frame:    "content",
              action:         "click->modal#close"
            }
          })

          super(*, **options)
        end
      end

      class OtherAction < UI::Button::Component
        def initialize(*, **options)
          options = merge_attributes(options, {
            class: "modal__secondary-action"
          })

          super(*, **options)
        end
      end
    end
  end
end
