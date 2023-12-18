# frozen_string_literal: true

module API
  module Reports
    class AttachmentsController < ApplicationController
      include ActiveStorage::SetCurrent

      resource_description do
        name "Pièces Jointes"
        formats ["json"]
      end

      api :POST, "/signalements/:id/documents", "Autorisation de téléchargement"
      description <<-DESC
        Le téléchargement de pièces jointes s'effectue sur un serveur dédié au stockage de fichiers.
        <br>
        Cette ressource permet d'obtenir une autorisation de téléchargement
        avant de pouvoir effectivement télécharger un fichier sur ce serveur.

        L'autorisation de téléchargement prends la forme d'une URL à usage unique pour télécharger votre fichier.
        <br>
        L'URL obtenue peut être utilisée telle quelle, dans une requête <code>PUT</code>, sans utiliser d'Access Token.

        Dans la réponse d'autorisation, vous obtenez aussi un <code>signed_id</code> qui permet d'associer
        ce fichier à un signalement.

        La pièce jointe sera associée au signalement après avoir été téléchargée sur notre serveur distant.
      DESC

      param :blob, Hash, "Attributs relatifs au fichier" do
        param :filename,     String,  "Nom du fichier",                      required: true
        param :byte_size,    Integer, "Taille du fichier (en octets)",       required: true
        param :checksum,     String,  "Checksum du fichier (MD5 en base64)", required: true
        param :content_type, String,  "Type MIME du fichier",                required: true
      end

      param :documents, String, "Signed ID du document", required: true

      returns code: 200, desc: "Autorisation de téléchargement" do
        property :attachment, Hash do
          property :id, String, "UUID de la pièce jointe"
        end
        property :direct_upload, Hash do
          property :url,     String, "URL de téléchargement"
          property :headers, Hash,   "En-têtes de téléchargement"
        end
      end

      def create
        @report = find_and_authorize_report

        blob_args = params
          .require(:blob)
          .permit(:filename, :byte_size, :checksum, :content_type, metadata: {})
          .to_h
          .symbolize_keys

        blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_args)
        attachment = ActiveStorage::Attachment.create(
          name:        "documents",
          record_type: @report.class.name,
          record_id:   @report.id,
          blob_id:     blob.id
        )

        #  render json: blob.as_json(root: false, methods: :signed_id).merge(direct_upload: {

        render json: {
          attachment:    { id: attachment.id },
          direct_upload: {
            url:     blob.service_url_for_direct_upload,
            headers: blob.service_headers_for_direct_upload
          }
        }
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
