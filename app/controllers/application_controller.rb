# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :verify_requested_format!

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
end
