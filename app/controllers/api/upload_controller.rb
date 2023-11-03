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

    returns code: 200, desc: "Obtention de votre lien de téléchargement"
    def create; end
  end
end
