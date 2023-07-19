# frozen_string_literal: true

module Admin
  module DDFIPs
    class CollectivitiesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_ddfip
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_ddfip, only: :index

      def index
        @collectivities = authorize_collectivities_scope
        @collectivities, @pagy = index_collection(@collectivities, nested: true)

        @collectivities = @collectivities.preload(:publisher)
      end

      private

      def load_and_authorize_ddfip
        @ddfip = DDFIP.find(params[:ddfip_id])

        authorize! @ddfip, to: :show?
        only_kept! @ddfip
      end

      def better_view_on_ddfip
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to admin_ddfip_path(@ddfip), status: :see_other
      end

      def authorize_collectivities_scope(as: :default)
        authorized(@ddfip.on_territory_collectivities, as:).strict_loading
      end
    end
  end
end
