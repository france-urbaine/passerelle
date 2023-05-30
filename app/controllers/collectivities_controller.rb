# frozen_string_literal: true

class CollectivitiesController < ApplicationController
  before_action :authorize!
  before_action :build_collectivities_scope
  before_action :authorize_collectivities_scope
  before_action :build_collectivity,     only: %i[new create]
  before_action :find_collectivity,      only: %i[show edit remove update destroy undiscard]
  before_action :authorize_collectivity, only: %i[show edit remove update destroy undiscard]

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @collectivities = @collectivities.kept.strict_loading
    @collectivities, @pagy = index_collection(@collectivities, nested: @parent)
  end

  def show
    only_kept! @collectivity
  end

  def new
    @background_url = referrer_path || parent_path || collectivities_path
  end

  def edit
    only_kept! @collectivity
    @background_url = referrer_path || collectivity_path(@collectivity)
  end

  def remove
    only_kept! @collectivity
    @background_url = referrer_path || collectivity_path(@collectivity)
  end

  def remove_all
    @collectivities = @collectivities.kept.strict_loading
    @collectivities = filter_collection(@collectivities)

    @background_url = referrer_path || collectivities_path(**selection_params)
  end

  def create
    @collectivity.assign_attributes(collectivity_params)
    @collectivity.save

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || parent_path || collectivities_path }
  end

  def update
    only_kept! @collectivity
    @collectivity.update(collectivity_params)

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || collectivities_path }
  end

  def destroy
    @collectivity = @collectivities.find(params[:id])
    @collectivity.discard

    respond_with @collectivity,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || collectivities_path
  end

  def undiscard
    @collectivity = @collectivities.find(params[:id])
    @collectivity.undiscard

    respond_with @collectivity,
      flash: true,
      location: redirect_path || referrer_path || collectivities_path
  end

  def destroy_all
    @collectivities = @collectivities.kept.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_discard_all

    respond_with @collectivities,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || collectivities_path
  end

  def undiscard_all
    @collectivities = @collectivities.discarded.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_undiscard_all

    respond_with @collectivities,
      flash: true,
      location: redirect_path || referrer_path || parent_path || collectivities_path
  end

  private

  def build_collectivities_scope
    @collectivities = Collectivity.all
  end

  def authorize_collectivities_scope
    @collectivities = authorized(@collectivities)
  end

  def build_collectivity
    @collectivity = @collectivities.build
  end

  def find_collectivity
    @collectivity = Collectivity.find(params[:id])
  end

  def authorize_collectivity
    authorize! @collectivity
  end

  def collectivity_params
    authorized(params.fetch(:collectivity, {}))
      .then { |input| CollectivityParamsParser.new(input, @parent).parse }
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
