# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  include ComponentsHelper
  include ActionPolicy::Behaviour

  # Delegate devise methods
  delegate :current_user, :signed_in?, to: :helpers

  # Setup policies context
  authorize :user, through: :current_user

  class LabelOrContent < self
    def initialize(label = nil)
      @label = label
      super()
    end

    def call
      @label || content
    end
  end

  def turbo_frame_request_id
    request.headers["Turbo-Frame"]
  end

  def turbo_frame_request?
    turbo_frame_request_id.present?
  end

  def current_organization
    current_user&.organization
  end

  def i18n_component_path
    component_path = self.class.name.delete_suffix("Component").underscore.tr("/", ".")

    "components.#{component_path}"
  end
end
