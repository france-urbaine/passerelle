# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include ControllerAutocomplete
  include ControllerItems
  include ControllerOrder
  include ControllerSearch

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

  %i[bad_request gone unauthorized forbidden not_found not_acceptable unprocessable_entity].each do |status|
    define_method(status) do
      respond_to do |format|
        # TODO: add templates to render statuses
        format.html { render(status:) }
        format.all  { head(status) }
      end
    end
  end

  # Variant
  # ----------------------------------------------------------------------------
  helper_method :turbo_frame_request_id

  def accept_variant
    request.headers["Accept-Variant"]&.downcase
  end

  def autocomplete_request?
    accept_variant == "autocomplete"
  end

  # FIXME: Turbo send the wrong Turbo-Frame header from forms
  # See https://github.com/hotwired/turbo/issues/577
  # Until this is fixed, we'll send a parameters to catch the good target frame
  #
  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end

  def turbo_frame_request_id
    params.fetch("Turbo-Frame", request.headers["Turbo-Frame"]) if turbo_frame_request?
  end

  def accept_request_variant
    request.variant = :turbo_frame  if turbo_frame_request?
    request.variant = :autocomplete if autocomplete_request?
  end
end
