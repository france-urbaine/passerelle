# frozen_string_literal: true

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  include ControllerAdvancedSearch
  include ControllerAutocompletion
  include ControllerCollections
  include ControllerDiscard
  include ControllerParams
  include ControllerStatuses
  include ControllerVariants
  include ControllerAudits

  prepend_before_action do
    Rails.logger.debug { "  Turbo-frame: #{turbo_frame_request_id.inspect}" } if turbo_frame_request?
    Rails.logger.debug { "  Accept-Variant: #{accept_variant.inspect}" } if accept_variant
  end

  before_action :accept_request_variant
  before_action :authenticate_user!
  before_action :verify_requested_format!
  after_action  :verify_authorized, if: -> { signed_in? && !devise_controller? }

  rescue_from "ActionPolicy::Unauthorized",          with: :forbidden
  rescue_from "ActiveRecord::RecordNotFound",        with: :not_found
  rescue_from "ControllerDiscard::RecordDiscarded",  with: :gone
  rescue_from "ControllerStatuses::InterruptAction", with: -> {}

  unless Rails.env.development?
    rescue_from "ActionController::InvalidAuthenticityToken", with: :expired_session
    rescue_from "ActionController::ParameterMissing",         with: :bad_request
    rescue_from "ActionController::BadRequest",               with: :bad_request
    rescue_from "AbstractController::ActionNotFound",         with: :not_found
    rescue_from "ActionController::RoutingError",             with: :not_found
    rescue_from "ActionController::UnknownFormat",            with: :not_acceptable
    rescue_from "Pagy::VariableError",                        with: :bad_request
  end

  respond_to :html

  layout lambda {
    if turbo_frame_request?
      "turbo_rails/frame"
    elsif signed_in?
      if request.subdomain == "api"
        "documentation"
      else
        "application"
      end
    else
      "public"
    end
  }

  helper_method :turbo_frame_request_id
  helper_method :turbo_frame_request?
  helper_method :current_organization

  def current_organization
    current_user&.organization
  end

  # Add more info to Lograge payload
  # See https://github.com/roidrage/lograge
  #
  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.request_id
  end

  # HACKME: We need a simpler way to render components from controllers.
  #
  # Rendering components from controllers requires to properly define content_type:
  # See https://viewcomponent.org/guide/getting-started.html#rendering-from-controllers
  #
  def render(*args, **options)
    options[:content_type] ||= "text/html" if args.size == 1 && args.first.is_a?(ViewComponent::Base)

    super(*args, **options)
  end
end
