# frozen_string_literal: true

class ExceptionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_requested_format!
  skip_after_action  :verify_authorized

  respond_to :json

  # This controller is used by exceptions_app to render error pages
  # in a context of a controller (with current_user, etc...)
  #
  # Methods from ControllerStatuses must be overrode to make them public.
  #
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

  # It is also used by components specs to provide a routed path independant from
  # any behavior linked to URL.
  #
  def testing
    return not_found unless Rails.env.test?

    render html: ""
  end
end
