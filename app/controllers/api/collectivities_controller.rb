# frozen_string_literal: true

module API
  class CollectivitiesController < ApplicationController
    before_action :authorize!

    resource_description do
      resource_id "collectivities"
      name        "Collectivités"
      formats     ["json"]
    end

    api :GET, "/collectivites", "Index des collectivités"
    description <<-DESC
      Cette ressource permet de lister les collectivités qui vous ont déclaré comme éditeur pour transmettre
      des données à Passerelle.

      L'UUID d'une collectivité est requis pour initialiser une transmission.

      La liste des collectivités est paginée à raison de 50 collectivités par page.
      <br>
      Il est possible de parcourir les pages avec le paramètre <code>page</code>.
      <br>
      Il est possible de rechercher une collectivité en particulier avec le paramètre <code>search</code>.
    DESC

    see "transmissions#create", "Initialisation d'une transmission"

    param :page, Integer, "Numéro de page", required: false
    param :search, String, "Critère de recherche", required: false

    returns code: 200 do
      property :collectivites, Array, desc: "Tableau de collectivités" do
        param :id, String, "UUID de la collectivité"
        param :name, String, "Nom de la collectivité"
        param :siren, String, "SIREN de la collectivité"
      end
    end

    def index
      @collectivities = build_and_authorize_scope
      @collectivities, @pagy = index_collection(@collectivities)

      respond_with @collectivities
    end

    private

    def build_and_authorize_scope
      authorized(Collectivity.all).strict_loading
    end
  end
end
