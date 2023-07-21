# frozen_string_literal: true

module Admin
  module Offices
    class CollectivitiesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_office
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_office, only: :index

      def index
        @collectivities = authorize_collectivities_scope
        @collectivities, @pagy = index_collection(@collectivities, nested: true)

        @collectivities = @collectivities.preload(:publisher)
      end

      private

      def load_and_authorize_office
        @office = Office.find(params[:office_id])

        authorize! @office, to: :show?
        only_kept! @office.ddfip, @office
      end

      def better_view_on_office
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to admin_office_path(@office), status: :see_other
      end

      def authorize_collectivities_scope(as: :default)
        authorized(@office.on_territory_collectivities, as:).strict_loading
      end
    end
  end
end
