# frozen_string_literal: true

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  include ControllerAutocompletion
  include ControllerCollections
  include ControllerDiscard
  include ControllerParams
  include ControllerStatuses
  include ControllerVariants

  prepend_before_action do
    Rails.logger.debug { "  Turbo-frame: #{turbo_frame_request_id.inspect}" } if turbo_frame_request?
    Rails.logger.debug { "  Accept-Variant: #{accept_variant.inspect}" } if accept_variant
  end

  before_action :accept_request_variant
  before_action :authenticate_user!
  before_action :verify_requested_format!

  rescue_from "ActionController::ParameterMissing", with: :bad_request
  rescue_from "ActionController::BadRequest",       with: :bad_request
  rescue_from "ActionPolicy::Unauthorized",         with: :forbidden
  rescue_from "ActiveRecord::RecordNotFound",       with: :not_found
  rescue_from "ControllerDiscard::RecordDiscarded", with: :gone

  unless Rails.env.development?
    rescue_from "AbstractController::ActionNotFound", with: :not_found
    rescue_from "ActionController::RoutingError",     with: :not_found
    rescue_from "ActionController::UnknownFormat",    with: :not_acceptable
  end

  respond_to :html

  helper_method :turbo_frame_request_id
  helper_method :turbo_frame_request?
end
