# frozen_string_literal: true

module Admin
  module Publishers
    class CollectivitiesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_publisher
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_publisher, only: :index

      def index
        @collectivities = authorize_collectivities_scope
        @collectivities, @pagy = index_collection(@collectivities, nested: true)
      end

      def new
        @collectivity = build_collectivity
        @referrer_path = referrer_path || admin_publisher_path(@publisher)
      end

      def create
        @collectivity = build_collectivity
        service = Collectivities::CreateService.new(@collectivity, collectivity_params, publisher: @publisher)
        result  = service.save

        respond_with result,
          flash: true,
          location: -> { redirect_path || admin_publisher_path(@publisher) }
      end

      def remove_all
        @collectivities = authorize_collectivities_scope
        @collectivities = filter_collection(@collectivities)
        @referrer_path = referrer_path || admin_publisher_path(@publisher)
      end

      def destroy_all
        @collectivities = authorize_collectivities_scope(as: :destroyable)
        @collectivities = filter_collection(@collectivities)
        @collectivities.quickly_discard_all

        respond_with @collectivities,
          flash: true,
          actions: undiscard_all_admin_publisher_collectivities_action(@publisher),
          location: redirect_path || admin_publisher_path(@publisher)
      end

      def undiscard_all
        @collectivities = authorize_collectivities_scope(as: :undiscardable)
        @collectivities = filter_collection(@collectivities)
        @collectivities.quickly_undiscard_all

        respond_with @collectivities,
          flash: true,
          location: redirect_path || referrer_path || admin_publisher_path(@publisher)
      end

      private

      def load_and_authorize_publisher
        @publisher = Publisher.find(params[:publisher_id])

        authorize! @publisher, to: :show?
        only_kept! @publisher
      end

      def better_view_on_publisher
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to admin_publisher_path(@publisher), status: :see_other
      end

      def authorize_collectivities_scope(as: :default)
        authorized(@publisher.collectivities, as:).strict_loading
      end

      def build_collectivity(...)
        authorize_collectivities_scope.build(...)
      end

      def collectivity_params
        authorized(params.fetch(:collectivity, {}))
      end
    end
  end
end
