# frozen_string_literal: true

module Territories
  module Regions
    class CollectivitiesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_region
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_region, only: :index

      def index
        @collectivities = authorized(@region.on_territory_collectivities).strict_loading
        @collectivities, @pagy = index_collection(@collectivities, nested: true)

        @collectivities = @collectivities.preload(:publisher) if allowed_to?(:show?, Publisher, namespace: Admin)
      end

      private

      def load_and_authorize_region
        @region = Region.find(params[:region_id])

        authorize! @region, to: :show?
        only_kept! @region
      end

      def better_view_on_region
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to territories_region_path(@region), status: :see_other
      end
    end
  end
end
