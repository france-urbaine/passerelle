# frozen_string_literal: true

module API
  class TransmissionsController < ApplicationController
    before_action :authorize!

    def create
      collectivity = find_and_authorize_collectivity

      @transmission = collectivity.transmissions.build(transmission_params)
      @transmission.publisher = current_publisher
      @transmission.oauth_application = current_application
      @transmission.save

      respond_with @transmission
    end

    def complete
      @transmission = current_publisher.transmissions.find(params[:id])

      return forbidden(error: t(".already_completed"))    if @transmission.completed?
      return bad_request(error: t(".reports_empty"))      if @transmission.reports.none?
      return bad_request(error: t(".reports_incomplete")) if @transmission.reports.incomplete.any?

      authorize! @transmission

      @service = Transmissions::CompleteService.new(@transmission)
      @result = @service.complete

      @transmission.reload.packages.preload(:reports) if @result.success?

      respond_with @result
    end

    private

    def find_and_authorize_collectivity
      current_publisher.collectivities.find(params[:collectivity_id]).tap do |collectivity|
        authorize! collectivity, to: :read?
      end
    end

    def transmission_params
      authorized(params.require(:transmission))
    end
  end
end
