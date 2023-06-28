# frozen_string_literal: true

module Modal
  class Component < ApplicationViewComponent
    renders_one :header, "LabelOrContent"
    renders_one :body, "LabelOrContent"

    renders_one :form, lambda { |**options, &block|
      self.form_options = options
      fields(**options, &block)
    }

    renders_one  :submit_action, "SubmitAction"
    renders_one  :close_action, lambda { |*args, **options|
      CloseAction.new(*args, **options, href: redirection_path)
    }

    renders_many :actions,       "Action"
    renders_many :other_actions, "OtherAction"
    renders_one :raw_actions

    attr_reader :redirection_path
    attr_accessor :form_options

    def initialize(redirection_path: nil)
      @redirection_path = redirection_path
      super()
    end

    protected

    def close_button
      helpers.button_component(
        icon: "x-mark",
        href: redirection_path,
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
