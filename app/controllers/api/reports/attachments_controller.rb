# frozen_string_literal: true

module API
  module Reports
    class AttachmentsController < ApplicationController
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
        property :id, String, "UUID du fichier"
        property :filename, String, "Nom du fichier"
        property :content_type, String, "Type du fichier"
        property :byte_size, Integer, "Taille du fichier"
        property :checksum, String, "Checksum du fichier"
        property :created_at, String, "Date de création du fichier"
        property :signed_id, String, "ID signé du fichier"
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

        # NOTE : preventing 'FileNotFound' issue when attaching blob to report
        @tempfile = Tempfile.new(blob_args[:filename])

        blob = ActiveStorage::Blob.create_and_upload!(
          filename: blob_args[:filename],
          io: File.open(@tempfile.path)
        )

        @report.documents.attach(blob.signed_id)

        render json: blob.as_json(root: false, methods: :signed_id).merge(direct_upload: {
          url: blob.service_url_for_direct_upload,
          headers: blob.service_headers_for_direct_upload
        })
      ensure
        @tempfile&.unlink
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
