# frozen_string_literal: true

class CollectivitiesController < ApplicationController
  before_action :authorize!
  before_action :load_and_authorize_parent
  before_action :autocompletion_not_implemented!, only: :index
  before_action :better_view_on_parent, only: :index

  def index
    @collectivities = build_and_authorize_scope
    @collectivities, @pagy = index_collection(@collectivities, nested: @parent)
  end

  def show
    @collectivity = find_and_authorize_collectivity
  end

  def new
    @collectivity = build_collectivity
    @referrer_path = referrer_path || parent_path || collectivities_path
  end

  def create
    @collectivity = build_collectivity(collectivity_params)
    @collectivity.save

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || parent_path || collectivities_path }
  end

  def edit
    @collectivity = find_and_authorize_collectivity
    @referrer_path = referrer_path || collectivity_path(@collectivity)
  end

  def update
    @collectivity = find_and_authorize_collectivity
    @collectivity.update(collectivity_params)

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || collectivities_path }
  end

  def remove
    @collectivity = find_and_authorize_collectivity
    @referrer_path = referrer_path || collectivity_path(@collectivity)
  end

  def destroy
    @collectivity = find_and_authorize_collectivity(allow_discarded: true)
    @collectivity.discard

    respond_with @collectivity,
      flash: true,
      actions: undiscard_action([:undiscard, @parent, @collectivity]),
      location: redirect_path || collectivities_path
  end

  def undiscard
    @collectivity = find_and_authorize_collectivity(allow_discarded: true)
    @collectivity.undiscard

    respond_with @collectivity,
      flash: true,
      location: redirect_path || referrer_path || collectivities_path
  end

  def remove_all
    @collectivities = build_and_authorize_scope
    @collectivities = filter_collection(@collectivities)
    @referrer_path = referrer_path || collectivities_path(**selection_params)
  end

  def destroy_all
    @collectivities = build_and_authorize_scope(as: :destroyable)
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_discard_all

    respond_with @collectivities,
      flash: true,
      actions: undiscard_action([:undiscard_all, @parent, :collectivities]),
      location: redirect_path || parent_path || collectivities_path
  end

  def undiscard_all
    @collectivities = build_and_authorize_scope(as: :undiscardable)
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_undiscard_all

    respond_with @collectivities,
      flash: true,
      location: redirect_path || referrer_path || parent_path || collectivities_path
  end

  private

  def load_and_authorize_parent
    # Override this method to load a @parent variable
  end

  def build_and_authorize_scope(as: :default)
    authorized(Collectivity.all, as:).strict_loading
  end

  def build_collectivity(...)
    build_and_authorize_scope.build(...)
  end

  def find_and_authorize_collectivity(allow_discarded: false)
    collectivity = Collectivity.find(params[:id])

    authorize! collectivity
    only_kept! collectivity unless allow_discarded

    collectivity
  end

  def collectivity_params
    authorized(params.fetch(:collectivity, {}))
      .then { |input| Collectivities::ParamsParserService.new(input, @parent).parse }
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
