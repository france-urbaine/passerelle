# frozen_string_literal: true

module API
  class UploadController < ActiveStorage::DirectUploadsController
    before_action :doorkeeper_authorize!
    skip_forgery_protection

    resource_description do
      resource_id "upload"
      name "Téléchargement d'un fichier"
      formats ["json"]
      deprecated false
      description <<-DESC
        Lien d'ouverture d'un canal de téléchargement de fichier.
      DESC
    end

    api :POST, "/upload", "Creation d'un lien de téléchargement"

    param :blob, Hash, "Attributs relatifs au fichier" do
      param :filename, String, "Nom du fichier", required: false
      param :byte_size, Integer, "Taille du fichier", required: false
      param :checksum, String, "Checksum du fichier", required: true
      param :content_type, String, "Type du fichier", required: false
    end

    returns code: 200, desc: "Obtention de votre lien de téléchargement" do
      param :id, String, "UUID du fichier"
      param :key, String, "Clé de téléchargement"
      param :filename, String, "Nom du fichier"
      param :content_type, String, "Type du fichier"
      param :metadata, Hash, "Métadonnées du fichier"
      param :service_name, String, "Nom du service de stockage"
      param :byte_size, Integer, "Taille du fichier"
      param :checksum, String, "Checksum du fichier"
      param :created_at, String, "Date de création du fichier"
      param :signed_id, String, "ID signé du fichier"
      param :attachable_sgid, String, "ID signé du fichier"
      param :direct_upload, Hash, "Lien de téléchargement" do
        param :url, String, "URL de téléchargement"
        param :headers, Hash, "Headers de téléchargement"
      end
    end

    def create; end
  end
end
