# frozen_string_literal: true

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  include ControllerCollections
  include ControllerParams

  before_action :verify_requested_format!
  before_action :accept_request_variant

  # Statuses
  # ----------------------------------------------------------------------------
  rescue_from "ActiveRecord::RecordNotFound",       with: :not_found
  rescue_from "ActionPolicy::Unauthorized",         with: :forbidden
  rescue_from "ActionController::ParameterMissing", with: :bad_request
  rescue_from "ActionController::BadRequest",       with: :bad_request

  unless Rails.env.development?
    rescue_from "ActionController::RoutingError",     with: :not_found
    rescue_from "AbstractController::ActionNotFound", with: :not_found
    rescue_from "ActionController::UnknownFormat",    with: :not_acceptable
  end

  %i[
    bad_request
    gone
    unauthorized
    forbidden
    not_found
    not_acceptable
    unprocessable_entity
    not_implemented
  ].each do |status|
    define_method(status) do
      respond_to do |format|
        # TODO: add templates to render statuses
        format.html { render(status:, template: "shared/statuses/#{status}") }
        format.all  { head(status) }
      end
    end
  end

  # Variants
  # ----------------------------------------------------------------------------
  helper_method :turbo_frame_request_id
  helper_method :turbo_frame_request?

  def accept_variant
    request.headers["Accept-Variant"]&.downcase
  end

  def autocomplete_request?
    accept_variant == "autocomplete"
  end

  def accept_request_variant
    request.variant = :turbo_frame  if turbo_frame_request?
    request.variant = :autocomplete if autocomplete_request?
  end
end
