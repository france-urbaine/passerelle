# frozen_string_literal: true

module API
  class TransmissionsController < ApplicationController
    before_action :authorize!

    def create
      @transmission = current_publisher.transmissions.build(transmission_params)
      @transmission.oauth_application = OauthApplication.find(current_application.id)
      authorize! @transmission
      @transmission.save

      respond_with @transmission
    end

    def complete
      @transmission = current_publisher.transmissions.find(params[:transmission_id])
      authorize! @transmission
      @service = Transmissions::CompleteService.new(@transmission)
      @service.complete

      respond_with @service
    end

    private

    def transmission_params
      authorized(params.require(:transmission).permit(:sandbox).merge(collectivity_id: params[:collectivity_id]))
    end
  end
end
