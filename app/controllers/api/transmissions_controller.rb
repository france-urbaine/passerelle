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
      @transmission = find_and_authorize_transmission

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

    def find_and_authorize_transmission
      current_publisher.transmissions.find(params[:id]).tap do |transmission|
        authorize! transmission, to: :read?
        forbidden! t(".already_completed")    if transmission.completed?
        bad_request! t(".reports_empty")      if transmission.reports.none?
        bad_request! t(".reports_incomplete") if transmission.reports.incomplete.any?
        authorize! transmission, to: :complete?
      end
    end

    def transmission_params
      authorized(params.require(:transmission))
    end
  end
end
