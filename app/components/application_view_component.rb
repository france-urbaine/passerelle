# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  class LabelOrContent < self
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      @label || content
    end
  end

  # Devise & ActionPolicy helpers
  delegate :current_user, :current_organization, :signed_in?, :allowed_to?, to: :helpers

  # Helpers methods
  delegate :svg_icon, :authorized_link_to, to: :helpers

  # Other components helpers
  delegate :button_component, :card_component, :modal_component, :datatable_component,
    :form_block_component, :checkboxes_component, :radio_buttons_component,
    to: :helpers
end
