# frozen_string_literal: true

module API
  class TransmissionsController < ApplicationController
    before_action :authorize!

    def create
      collectivity = find_and_authorize_collectivity
      @transmission = collectivity.transmissions.build(transmission_params)
      @transmission.publisher = current_publisher
      @transmission.oauth_application = OauthApplication.find(current_application.id)
      @transmission.save

      respond_with @transmission
    end

    def complete
      @transmission = current_publisher.transmissions.includes(packages: :reports).find(params[:transmission_id])
      authorize! @transmission
      @service = Transmissions::CompleteService.new(@transmission)
      @result = @service.complete

      @transmission.packages.reload if @result.success?

      respond_with @result
    end

    private

    def find_and_authorize_collectivity
      current_publisher.collectivities.find(params[:collectivity_id]).tap do |collectivity|
        authorize! collectivity
      end
    end

    def transmission_params
      authorized(params.require(:transmission))
    end
  end
end
