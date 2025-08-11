# frozen_string_literal: true

module API
  module Reports
    class DocumentsController < ApplicationController
      include ActiveStorage::SetCurrent

      resource_description do
        name "Pièces Jointes"
        formats ["json"]
      end

      api :POST, "/signalements/:id/documents", "Autorisation de téléchargement"
      description <<-DESC
        Le téléchargement de pièces jointes s'effectue sur un serveur dédié au stockage de fichiers.
        <br>
        Cette ressource permet d'obtenir une URL pré-signée afin de pouvoir télécharger le fichier sur ce serveur.

        L'URL obtenue est à usage unique. Elle peut être utilisée telle quelle, dans une requête <code>PUT</code>, sans utiliser d'Access Token.
      DESC

      param :file, Hash, "Attributs relatifs au fichier" do
        param :filename,     String,  "Nom du fichier",                                required: true
        param :byte_size,    Integer, "Taille du fichier (en octets)",                 required: true
        param :checksum,     String,  "Checksum du fichier (MD5, converti en base64)", required: true
        param :content_type, String,  "Type MIME du fichier",                          required: true
      end

      returns code: 200, desc: "Autorisation de téléchargement" do
        property :document, Hash do
          property :id, String, "UUID de la pièce jointe"
        end
        property :direct_upload, Hash do
          property :url,     String, "URL pré-signée de téléchargement"
          property :headers, Hash,   "En-têtes nécessaires au téléchargement"
        end
      end

      def create
        @report = find_and_authorize_report

        blob_args = params
          .expect(
            file: [
              :filename, :byte_size, :checksum, :content_type, { metadata: {} }
            ]
          )
          .to_h
          .symbolize_keys

        blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_args)
        attachment = ActiveStorage::Attachment.create(
          name:        "documents",
          record_type: @report.class.name,
          record_id:   @report.id,
          blob_id:     blob.id
        )

        render json: {
          document:    {
            id: attachment.id
          },
          direct_upload: {
            url:     blob.service_url_for_direct_upload,
            headers: blob.service_headers_for_direct_upload
          }
        }
      end

      private

      def find_and_authorize_report
        Report.find(params[:report_id]).tap do |report|
          only_kept! report
          forbidden! t(".already_transmitted") if report.transmitted?
          authorize! report, to: :attach?, with: API::ReportPolicy
        end
      end
    end
  end
end
