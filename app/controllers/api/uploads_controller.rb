# frozen_string_literal: true

module API
  class UploadsController < ActiveStorage::DirectUploadsController
    before_action :doorkeeper_authorize!
    skip_forgery_protection

    resource_description do
      resource_id "uploads"
      name        "Document"
      formats     ["json"]
    end

    api :POST, "/documents", "Autorisation de téléchargement"

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
    DESC

    see "attachments#create", "Sauvegarde d'une pièce jointe"

    param :blob, Hash, "Attributs relatifs au fichier" do
      param :filename,     String,  "Nom du fichier",                      required: true
      param :byte_size,    Integer, "Taille du fichier (en octets)",       required: true
      param :checksum,     String,  "Checksum du fichier (MD5 en base64)", required: true
      param :content_type, String,  "Type MIME du fichier",                required: true
    end

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

    # rubocop:disable AutoCorrectLint/UselessMethodDefinition
    def create = super()
    # rubocop:enable AutoCorrectLint/UselessMethodDefinition
  end
end
