# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  include ComponentsHelper
  include ActionPolicy::Behaviour

  # Delegate devise methods
  delegate :current_user, :signed_in?, to: :helpers

  # Delegate few helpers (to convert to component)
  delegate :authorized_link_to, to: :helpers

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
end
