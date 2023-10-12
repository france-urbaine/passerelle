# frozen_string_literal: true

module API
  class ReportsController < ApplicationController
    before_action :authorize!

    resource_description do
      resource_id "reports"
      name  "Signalement"
      error 404, "Missing"
      formats ["json"]
      deprecated false
      description <<-DESC
        Un signalement fait aux DDFIPs de la part d'une collectivité.
      DESC
    end

    api! "Création d'un signalement"
    description <<-DESC
      Ce endpoint permet de créer un signalement.

      Seul un signalement à la fois peut être créé.
    DESC

    returns code: 200, desc: "En cas de succès, retourne l'identifiant du signalement."
    returns code: 404, desc: "Transmission n'existe pas ou n'appartient pas à l'éditeur."
    returns code: 422, desc: "Signalement invalide."
    returns code: 403, desc: "Transmission est déja complétée."

    def create
      transmission = find_and_authorize_transmission

      @report = transmission.reports.build
      @report.collectivity = transmission.collectivity
      @report.publisher    = current_publisher

      API::Reports::CreateService.new(@report, reports_params).save

      respond_with @report
    end

    private

    def find_and_authorize_transmission
      current_publisher.transmissions.find(params[:transmission_id]).tap do |transmission|
        authorize! transmission, to: :read?
        forbidden! t(".already_completed") if transmission.completed?
        authorize! transmission, to: :fill?
      end
    end

    def reports_params
      authorized(params.require(:report))
    end
  end
end
