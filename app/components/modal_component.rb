# frozen_string_literal: true

class ModalComponent < ViewComponent::Base
  renders_one :header, "Header"
  renders_one :body, "Body"
  renders_one :form, "Form"

  renders_many :actions, ::ButtonComponent

  renders_many :other_actions, "OtherAction"
  renders_one  :submit_action, "SubmitAction"
  renders_one  :close_action, "CloseAction"

  def initialize(redirection_path: nil)
    @redirection_path = redirection_path
    super()
  end

  def with_close_action(*, **, &)
    set_slot(:close_action, nil, *, **, href: @redirection_path, &)
  end

  protected

  def close_button
    helpers.button_component(
      icon: "x-mark",
      href: @redirection_path,
      class: "modal__close-button",
      aria: { label: "Fermer la fenêtre de dialogue" },
      data: {
        turbo_frame: "content",
        action:      "click->modal#close"
      }
    )
  end

  # Slots
  # ----------------------------------------------------------------------------
  class LabelOrContent < ViewComponent::Base
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      @label || content
    end
  end

  class Header < LabelOrContent; end
  class Body < LabelOrContent; end

  class Form < ViewComponent::Base
    attr_reader :form_options

    def initialize(**form_options)
      @form_options = form_options
      super()
    end

    def call
      content
    end
  end

  class OtherAction < ::ButtonComponent
    def initialize(*, **options)
      options[:class] ||= ""
      options[:class] += " modal__secondary-action"

      super(*, **options)
    end
  end

  class CloseAction < ::ButtonComponent
    def initialize(*, **options)
      options[:class] ||= ""
      options[:class] += " modal__close-action"

      options[:data] ||= {}
      options[:data][:turbo_frame] ||= "content"
      options[:data][:action]      ||= "click->modal#close"

      super(*, **options)
    end
  end

  class SubmitAction < ::ButtonComponent
    def initialize(*, **)
      super(*, **, primary: true, type: "submit")
    end
  end
end
