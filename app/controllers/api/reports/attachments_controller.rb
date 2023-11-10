# frozen_string_literal: true

module API
  module Reports
    class AttachmentsController < ApplicationController
      resource_description do
        name "Pièces Jointes"
        formats ["json"]
      end

      api :POST, "/signalements/:id/documents", "Association d'un fichier à un signalement"
      description <<-DESC
        Cette ressource permet d'ajouter une pièce jointe à un signalement.

        La pièce jointe doit préalablement avoir été téléchargée sur notre serveur distant.
      DESC

      see "uploads#create", "Obtenir un lien de téléchargement"

      param :documents, String, "Signed ID du document", required: true

      returns code: 200, desc: "Document relier au signalement"
      def create
        @report = find_and_authorize_report
        @report.documents.attach(params[:documents])

        head :no_content
      end

      def destroy
        @report = find_and_authorize_report
        @report.documents.find(params[:id]).purge_later

        head :no_content
      end

      private

      def find_and_authorize_report
        Report.find(params[:report_id]).tap do |report|
          only_kept! report
          forbidden! t(".already_packed") if report.packed?
          authorize! report, to: :attach?, with: API::ReportPolicy
        end
      end
    end
  end
end
