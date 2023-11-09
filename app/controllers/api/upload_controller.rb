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

    description <<-DESC
      Cette ressource permet de créer un canal de téléchargement.

      Afin de pouvoir attacher un document a un signalement il faut au préalable télécharger le fichier sur notre serveur distant.

      Ce point d'API permet d'ouvrir un canal de téléchargement et de nous fournir un lien et un id en retours.
    DESC

    see "attachments#create", "Sauvegarde d'une pièce jointe"

    param :blob, Hash, "Attributs relatifs au fichier" do
      param :filename, String, "Nom du fichier", required: false
      param :byte_size, Integer, "Taille du fichier", required: false
      param :checksum, String, "Checksum du fichier", required: true
      param :content_type, String, "Type du fichier", required: false
    end

    returns code: 200, desc: "Obtention de votre lien de téléchargement" do
      property :id, String, "UUID du fichier"
      property :key, String, "Clé de téléchargement"
      property :filename, String, "Nom du fichier"
      property :content_type, String, "Type du fichier"
      property :metadata, Hash, "Métadonnées du fichier"
      property :service_name, String, "Nom du service de stockage"
      property :byte_size, Integer, "Taille du fichier"
      property :checksum, String, "Checksum du fichier"
      property :created_at, String, "Date de création du fichier"
      property :signed_id, String, "ID signé du fichier"
      property :attachable_sgid, String, "ID signé du fichier"
      property :direct_upload, Hash, "Lien de téléchargement" do
        property :url, String, "URL de téléchargement"
        property :headers, Hash, "Headers de téléchargement"
      end
    end

    # rubocop:disable AutoCorrectLint/UselessMethodDefinition
    def create = super()
    # rubocop:enable AutoCorrectLint/UselessMethodDefinition
  end
end
