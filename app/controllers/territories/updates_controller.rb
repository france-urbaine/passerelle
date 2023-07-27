# frozen_string_literal: true

module Territories
  class UpdatesController < ApplicationController
    before_action :authorize!

    def edit
      @referrer_path = referrer_path || territories_communes_path
    end

    def update
      @service = Territories::UpdateService.new(update_params)
      @result  = @service.perform_later

      respond_with @result,
        flash: true,
        location: -> { redirect_path || territories_communes_path }
    end

    protected

    def implicit_authorization_target
      :updates
    end

    def update_params
      params.permit(:communes_url, :epcis_url)
    end
  end
end
