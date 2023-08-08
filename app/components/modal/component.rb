# frozen_string_literal: true

module Modal
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
    renders_one  :close_action, lambda { |*args, **options|
      CloseAction.new(*args, **options, href: referrer)
    }

    renders_many :actions,       "Action"
    renders_many :other_actions, "OtherAction"
    renders_one :raw_actions

    renders_many :hidden_fields, HiddenField::Component

    attr_reader :referrer
    attr_accessor :form_options

    def initialize(referrer: nil)
      @referrer = referrer
      super()
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
    class SubmitAction < ::Button::Component
      def initialize(*args, **options)
        super(*args, **options, primary: true, type: "submit")
      end
    end

    class CloseAction < ::Button::Component
      def initialize(*args, **options)
        options[:class] ||= ""
        options[:class] += " modal__close-action"

        options[:data] ||= {}
        options[:data][:turbo_frame] ||= "content"
        options[:data][:action]      ||= "click->modal#close"

        super(*args, **options)
      end
    end

    class Action < ::Button::Component
    end

    class OtherAction < ::Button::Component
      def initialize(*args, **options)
        options[:class] ||= ""
        options[:class] += " modal__secondary-action"

        super(*args, **options)
      end
    end
  end
end
