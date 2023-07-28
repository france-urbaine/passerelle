# frozen_string_literal: true

class ExceptionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_requested_format!
  skip_after_action  :verify_authorized

  respond_to :json

  # Overwrite methods from ControllerStatuses to make them public

  %i[
    not_found
    not_acceptable
    unprocessable_entity
    internal_server_error
  ].each do |status|
    define_method(status) do
      super()
    end
  end
end
