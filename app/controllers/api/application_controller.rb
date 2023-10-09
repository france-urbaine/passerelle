# frozen_string_literal: true

module API
  class ApplicationController < ActionController::Base
    self.responder = ApplicationResponder

    include ControllerDiscard
    include ControllerStatuses

    skip_forgery_protection

    before_action :doorkeeper_authorize!
    before_action :verify_requested_format!
    after_action  :verify_authorized, if: -> { signed_in? && !devise_controller? }

    authorize :publisher, through: :current_publisher

    rescue_from "Doorkeeper::Errors::TokenForbidden", with: :forbidden
    rescue_from "Doorkeeper::Errors::TokenUnknown",   with: :token_unknown
    rescue_from "Doorkeeper::Errors::TokenExpired",   with: :token_expired
    rescue_from "Doorkeeper::Errors::TokenRevoked",   with: :token_revoked

    rescue_from "ActionPolicy::Unauthorized",          with: :forbidden
    rescue_from "ActiveRecord::RecordNotFound",        with: :not_found
    rescue_from "ControllerDiscard::RecordDiscarded",  with: :gone
    rescue_from "ControllerStatuses::InterruptAction", with: -> { }

    unless Rails.env.development?
      rescue_from "ActionController::ParameterMissing", with: :bad_request
      rescue_from "ActionController::BadRequest",       with: :bad_request
      rescue_from "AbstractController::ActionNotFound", with: :not_found
      rescue_from "ActionController::RoutingError",     with: :not_found
      rescue_from "ActionController::UnknownFormat",    with: :not_acceptable
      rescue_from "Pagy::VariableError",                with: :bad_request
    end

    respond_to :json

    private

    def current_application
      @current_application ||= doorkeeper_token&.application
    end

    def current_publisher
      @current_publisher ||= current_application&.owner
    end

    %i[
      token_unknown
      token_expired
      token_revoked
    ].each do |exception_name|
      define_method(exception_name) do
        status = :unauthorized

        respond_to do |format|
          format.html do
            render status:, template: "shared/statuses/token_unknown", layout: "public"
          end

          format.json do
            error = I18n.t(exception_name, scope: "status", default: "")

            if error.present?
              render status:, json: { error: }
            else
              head status
            end
          end

          format.all { head status }
        end
      end
    end
  end
end
