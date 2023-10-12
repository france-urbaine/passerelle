# frozen_string_literal: true

module API
  class TransmissionsController < ApplicationController
    before_action :authorize!

    resource_description do
      resource_id "transmissions"
      name "Transmission"
      formats ["json"]
      deprecated false
      description <<-DESC
        Une transmission d'un ou plusieurs signalements à une DDFIP
      DESC
    end

    api! "Créer une transmission"
    returns code: 201, desc: "La transmission nouvellement créée." do
      property :id, String, desc: "ID de la transmission"
    end
    returns code: 404, desc: "Collectivité n'appartient pas à l'éditeur."
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

    api! "Completer une transmission"
    returns code: 200, desc: "La transmission à été complétée.
      Les signalements sont entre les mains des DDFIPs concernées." do
      property :id, String, desc: "ID de la transmission"
      property :completed_at, DateTime, desc: "Date de la complétion de la transmission"
      property :packages, array_of: Hash, desc: "Liste des paquets" do
        property :id, String, desc: "ID du paquet"
        property :name, String, desc: "Nom du paquet"
        property :reference, String, desc: "Code référentiel du paquet"
        property :reports, array_of: Hash, desc: "Liste des signalements" do
          property :id, String, desc: "ID du signalement"
          property :reference, String, desc: "Code référentiel du signalement"
        end
      end
    end
    returns code: 404, desc: "Transmission n'existe pas ou n'appartient pas à l'éditeur."
    returns code: 403, desc: "Transmission est déja complétée."
    returns code: 400, desc: "Signalements absents ou incomplets."
    description <<-DESC
      Ce endpoint permet de compléter une transmission au nom d'une collectivité.

      Il faut que la transmission continenne au moins un signalement et que tous les signalements soient complets.
    DESC
    see "reports#create", "Créer un signalement"
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
