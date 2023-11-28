# frozen_string_literal: true

module Territories
  module Communes
    class ArrondissementsController < ApplicationController
      before_action -> { authorize!(with: CommunePolicy) }
      before_action :load_and_authorize_commune
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_commune, only: :index

      def index
        @arrondissements = authorized(@commune.arrondissements).strict_loading
        @arrondissements, @pagy = index_collection(@arrondissements, nested: true)
      end

      private

      def load_and_authorize_commune
        @commune = Commune.find(params[:commune_id])

        authorize! @commune, to: :show?
        only_kept! @commune
      end

      def better_view_on_commune
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to territories_commune_path(@commune), status: :see_other
      end
    end
  end
end
