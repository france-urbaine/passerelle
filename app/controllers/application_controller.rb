# frozen_string_literal: true

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  include ControllerAutocompletion
  include ControllerCollections
  include ControllerParams

  before_action :verify_requested_format!
  before_action :accept_request_variant

  before_action do
    Rails.logger.debug { "Turbo-frame : #{turbo_frame_request_id}" if turbo_frame_request? }
    Rails.logger.debug { "Accept-Variant : #{accept_variant}" if accept_variant }
  end

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
    unauthorized
    forbidden
    not_acceptable
    unprocessable_entity
    not_implemented
  ].each do |status|
    define_method(status) do
      respond_to do |format|
        format.html { render status:, template: "shared/statuses/#{status}" }
        format.all { head status }
      end
    end
  end

  def not_found(exception_or_model = nil)
    @model_not_found =
      case exception_or_model
      when ActiveRecord::RecordNotFound then exception_or_model.model
      when ApplicationRecord            then model.name
      when String                       then model
      end

    if turbo_frame_request_id == "modal"
      request.variant = :modal
      @background_url = referrer_path
    end

    respond_to do |format|
      format.html { render status: :not_found, template: "shared/statuses/not_found" }
      format.all { head :not_found }
    end
  end

  def gone(record = nil)
    @record_discarded = record

    if turbo_frame_request_id == "modal"
      request.variant = :modal
      @background_url = referrer_path
    end

    respond_to do |format|
      format.html { render status: :gone, template: "shared/statuses/gone" }
      format.all { head :gone }
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
