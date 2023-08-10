# frozen_string_literal: true

class ApplicationViewComponent < ViewComponent::Base
  include ComponentsHelper

  delegate :current_user, :current_organization,
    :signed_in?, :allowed_to?,
    :authorized_link_to, :svg_icon,
    to: :helpers

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
end
