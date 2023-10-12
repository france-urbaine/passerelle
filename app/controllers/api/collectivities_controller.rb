# frozen_string_literal: true

module API
  class CollectivitiesController < ApplicationController
    before_action :authorize!

    resource_description do
      resource_id "collectivities"
      name "Collectivités"
      short "Collectivité"
      formats ["json"]
      meta icon: "building-library"

      description <<-DESC
        Une collectivité territoriale
      DESC
    end

    def_param_group :collectivity do
      param :id, String, "ID de la collectivité"
      param :name, String, "Nom de la collectivité"
      param :siren, String, "SIREN de la collectivité"
      param :territory_type, String, "Type de territoire", meta: { enum: "territory_type" }
    end

    api! "Lister les collectivités"
    description <<-DESC
      Ce endpoint permet de lister les collectivités.

      Seules les collectivités associées à votre éditeur sont retournées.
    DESC
    returns code: 200, desc: "En cas de succès, retourne la liste des collectivités." do
      property :collectivites, array_of: Hash, desc: "Tableau de collectivités" do
        param_group :collectivity
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
