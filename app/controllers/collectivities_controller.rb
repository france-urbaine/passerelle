# frozen_string_literal: true

class CollectivitiesController < ApplicationController
  respond_to :html

  before_action do
    @collectivities_scope ||= Collectivity.all
  end

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @collectivities = @collectivities_scope.kept.strict_loading
    @collectivities, @pagy = index_collection(@collectivities, nested: @parent)
  end

  def show
    @collectivity = @collectivities_scope.find(params[:id])
    gone(@collectivity) if @collectivity.discarded?
  end

  def new
    @collectivity = @collectivities_scope.build
    @background_url = referrer_path || parent_path || collectivities_path
  end

  def edit
    @collectivity = @collectivities_scope.find(params[:id])
    return gone(@collectivity) if @collectivity.discarded?

    @background_url = referrer_path || collectivity_path(@collectivity)
  end

  def remove
    @collectivity = @collectivities_scope.find(params[:id])
    return gone(@collectivity) if @collectivity.discarded?

    @background_url = referrer_path || collectivity_path(@collectivity)
  end

  def remove_all
    @collectivities = @collectivities_scope.kept.strict_loading
    @collectivities = filter_collection(@collectivities)
    @background_url = referrer_path || collectivities_path(**selection_params)
  end

  def create
    @collectivity = @collectivities_scope.build(collectivity_params)
    @collectivity.save

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || parent_path || collectivities_path }
  end

  def update
    @collectivity = @collectivities_scope.find(params[:id])
    return gone(@collectivity) if @collectivity.discarded?

    @collectivity.update(collectivity_params)

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || collectivities_path }
  end

  def destroy
    @collectivity = @collectivities_scope.find(params[:id])
    @collectivity.discard

    respond_with @collectivity,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || collectivities_path
  end

  def undiscard
    @collectivity = @collectivities_scope.find(params[:id])
    @collectivity.undiscard

    respond_with @collectivity,
      flash: true,
      location: redirect_path || referrer_path || collectivities_path
  end

  def destroy_all
    @collectivities = @collectivities_scope.kept.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_discard_all

    respond_with @collectivities,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || collectivities_path
  end

  def undiscard_all
    @collectivities = @collectivities_scope.discarded.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_undiscard_all

    respond_with @collectivities,
      flash: true,
      location: redirect_path || referrer_path || parent_path || collectivities_path
  end

  private

  def parent_path
    url_for(@parent) if @parent
  end

  def collectivity_params
    params
      .fetch(:collectivity, {})
      .then { |input| CollectivityParamsParser.new(input).parse }
      .permit(
        :territory_type, :territory_id, :publisher_id, :name, :siren,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone
      )
  end
end
