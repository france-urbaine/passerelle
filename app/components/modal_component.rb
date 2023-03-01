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

  # def with_form(**options, &)
  #   set_slot(:form, nil, **options)

  #   capture do
  #     helpers.fields(**options, &)
  #   end
  # end

  # def with_submit_action(label, &)
  #   with_primary_action(label, type: "submit", &)
  # end

  def with_close_action(label, **options, &)
    set_slot(:close_action, nil, label, **options, href: @redirection_path, &)
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
  class Header < ViewComponent::Base
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      @label || content
    end
  end

  class Body < ViewComponent::Base
    def call
      content
    end
  end

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
    def initialize(label, **options)
      options[:class] ||= ""
      options[:class] += " modal__secondary-action"

      super(label, **options)
    end
  end

  class CloseAction < ::ButtonComponent
    def initialize(label, **options)
      options[:class] ||= ""
      options[:class] += " modal__close-action"

      options[:data] ||= {}
      options[:data][:turbo_frame] ||= "content"
      options[:data][:action]      ||= "click->modal#close"

      super(label, **options)
    end
  end

  class SubmitAction < ::ButtonComponent
    def initialize(label, **options)
      super(label, **options, primary: true, type: "submit")
    end
  end
end
