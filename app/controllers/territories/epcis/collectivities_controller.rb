# frozen_string_literal: true

module Territories
  module EPCIs
    class CollectivitiesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_epci
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_epci, only: :index

      def index
        @collectivities = authorized(@epci.on_territory_collectivities).strict_loading
        @collectivities, @pagy = index_collection(@collectivities, nested: true)

        @collectivities = @collectivities.preload(:publisher) if allowed_to?(:show?, Publisher, namespace: Admin)
      end

      private

      def load_and_authorize_epci
        @epci = EPCI.find(params[:epci_id])

        authorize! @epci, to: :show?
        only_kept! @epci
      end

      def better_view_on_epci
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to territories_epci_path(@epci), status: :see_other
      end
    end
  end
end
