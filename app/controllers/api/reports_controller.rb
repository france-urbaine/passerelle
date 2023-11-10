# frozen_string_literal: true

module API
  class ReportsController < ApplicationController
    before_action :authorize!

    resource_description do
      resource_id "reports"
      name        "Signalement"
      formats     ["json"]
    end

    api :POST, "/transmission/:id/signalements", "Création d'un signalement"
    description <<-DESC
      Cette ressource permet de créer un signalement.

      Une transmission doit être préalablement établie :
      l'UUID de la transmission est ainsi requis pour créer un signalement.
      Il n'y a aucune limite au nombre de signalements qui peuvent être créés dans une même transmission.

      La liste des champs requis dépends du type de signalement, de l'anomalie signalée et parfois de certains autres
      champs.
      Consultez la liste des champs requis pour plus de détails (bientôt disponible).

      L'UUID du signalement nouvellement créé est retourné.
      <br>
      Conservez-le pour surveiller et obtenir des mises à jour du signalement.
    DESC

    see "transmissions#create",   "Initialisation d'une transmission"
    see "transmissions#complete", "Finalisation d'une transmission"

    param :id, String, "UUID de la transmission", required: true
    param :report, Hash, "Signalement", required: true

    returns code: 201, desc: "Le signalement est créé" do
      property :report, Hash do
        property :id, String, "UUID du signalement créé"
      end
    end

    returns code: 422, desc: "Des champs ne sont pas valides" do
      property :errors, Hash, "Rapport d'erreurs"
    end

    error 400, "Le champ `report` est vide."
    error 404, "La tranmission n'existe pas ou n'a pas été trouvée."
    error 403, "La transmission a déjà été complétée."
    error 422, "Certains champs ne sont pas valides."

    def create
      transmission = find_and_authorize_transmission

      @report              = transmission.reports.build
      @report.collectivity = transmission.collectivity
      @report.sandbox      = transmission.sandbox
      @report.publisher    = current_publisher

      API::Reports::CreateService.new(@report, reports_params).save

      respond_with @report, status: :created
    end

    private

    def find_and_authorize_transmission
      current_application.transmissions.find(params[:transmission_id]).tap do |transmission|
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
