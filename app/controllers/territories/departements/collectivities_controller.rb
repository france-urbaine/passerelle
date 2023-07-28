# frozen_string_literal: true

module Territories
  module Departements
    class CollectivitiesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_departement
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_departement, only: :index

      def index
        @collectivities = authorized(@departement.on_territory_collectivities).strict_loading
        @collectivities, @pagy = index_collection(@collectivities, nested: true)

        @collectivities = @collectivities.preload(:publisher) if allowed_to?(:show?, Publisher, namespace: Admin)
      end

      private

      def load_and_authorize_departement
        @departement = Departement.find(params[:departement_id])

        authorize! @departement, to: :show?
        only_kept! @departement
      end

      def better_view_on_departement
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to territories_departement_path(@departement), status: :see_other
      end
    end
  end
end
