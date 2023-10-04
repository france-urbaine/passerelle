# frozen_string_literal: true

module API
  class TransmissionsController < ApplicationController
    before_action :authorize!

    resource_description do
      resource_id "transmission"
      name "Transmission"
      formats ["json"]
      deprecated false
      meta icon: "archive-box"
      description <<-DESC
        Une transmission de plusieurs signalements à une DDFIP
      DESC
    end

    api! "Créer une transmission"
    returns code: 201, desc: "La transmission nouvellement créée."
    param :sandbox, :bool, required: false, default_value: false
    description <<-DESC
      Ce endpoint permet de créer une transmission au nom d'une collectivité.
    DESC
    see "collectivities#index", "Lister les collectivités"
    def create
      collectivity = find_and_authorize_collectivity

      @transmission = collectivity.transmissions.build(transmission_params)
      @transmission.publisher = current_publisher
      @transmission.oauth_application = current_application
      @transmission.save

      respond_with @transmission
    end

    api!
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
      authorized(params.fetch(:transmission, {}))
    end
  end
end
