# frozen_string_literal: true

module Admin
  class CollectivitiesController < ApplicationController
    before_action :authorize!
    before_action :autocompletion_not_implemented!, only: :index

    def index
      @collectivities = authorize_collectivities_scope
      @collectivities, @pagy = index_collection(@collectivities)

      @collectivities = @collectivities.preload(:publisher)
    end

    def show
      @collectivity = find_and_authorize_collectivity
    end

    def new
      @collectivity = build_collectivity
      @referrer_path = referrer_path || admin_collectivities_path
    end

    def create
      @collectivity = build_collectivity
      service = ::Collectivities::CreateService.new(@collectivity, collectivity_params)
      result  = service.save

      respond_with result,
        flash: true,
        location: -> { redirect_path || admin_collectivities_path }
    end

    def edit
      @collectivity = find_and_authorize_collectivity
      @referrer_path = referrer_path || admin_collectivity_path(@collectivity)
    end

    def update
      @collectivity = find_and_authorize_collectivity
      service = ::Collectivities::UpdateService.new(@collectivity, collectivity_params)
      result  = service.save

      respond_with result,
        flash: true,
        location: -> { redirect_path || admin_collectivities_path }
    end

    def remove
      @collectivity = find_and_authorize_collectivity
      @referrer_path = referrer_path || admin_collectivity_path(@collectivity)
      @redirect_path = referrer_path unless referrer_path&.include?(admin_collectivity_path(@collectivity))
    end

    def destroy
      @collectivity = find_and_authorize_collectivity(allow_discarded: true)
      @collectivity.discard

      respond_with @collectivity,
        flash: true,
        actions: undiscard_admin_collectivity_action(@collectivity),
        location: redirect_path || admin_collectivities_path
    end

    def undiscard
      @collectivity = find_and_authorize_collectivity(allow_discarded: true)
      @collectivity.undiscard

      respond_with @collectivity,
        flash: true,
        location: redirect_path || referrer_path || admin_collectivities_path
    end

    def remove_all
      @collectivities = authorize_collectivities_scope
      @collectivities = filter_collection(@collectivities)
      @referrer_path = referrer_path || admin_collectivities_path(**selection_params)
    end

    def destroy_all
      @collectivities = authorize_collectivities_scope(as: :destroyable)
      @collectivities = filter_collection(@collectivities)
      @collectivities.quickly_discard_all

      respond_with @collectivities,
        flash: true,
        actions: undiscard_all_admin_collectivities_action,
        location: redirect_path || admin_collectivities_path
    end

    def undiscard_all
      @collectivities = authorize_collectivities_scope(as: :undiscardable)
      @collectivities = filter_collection(@collectivities)
      @collectivities.quickly_undiscard_all

      respond_with @collectivities,
        flash: true,
        location: redirect_path || referrer_path || admin_collectivities_path
    end

    private

    def authorize_collectivities_scope(as: :default)
      authorized(Collectivity.all, as:).strict_loading
    end

    def build_collectivity(...)
      authorize_collectivities_scope.build(...)
    end

    def find_and_authorize_collectivity(allow_discarded: false)
      collectivity = Collectivity.find(params[:id])

      authorize! collectivity
      only_kept! collectivity unless allow_discarded

      collectivity
    end

    def collectivity_params
      authorized(params.fetch(:collectivity, {}))
    end
  end
end
