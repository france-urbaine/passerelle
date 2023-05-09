# frozen_string_literal: true

class CollectivitiesController < ApplicationController
  respond_to :html

  def index
    @collectivities = Collectivity.kept.strict_loading
    @collectivities, @pagy = index_collection(@collectivities)

    respond_with @collectivities do |format|
      format.html.autocomplete { not_implemented }
    end
  end

  def show
    @collectivity = Collectivity.find(params[:id])

    gone(@collectivity) if @collectivity.discarded?
  end

  def new
    @collectivity = Collectivity.new(collectivity_params)
    @background_url = referrer_path || collectivities_path
  end

  def edit
    @collectivity = Collectivity.find(params[:id])
    return gone(@collectivity) if @collectivity.discarded?

    @background_url = referrer_path || collectivity_path(@collectivity)
  end

  def remove
    @collectivity = Collectivity.find(params[:id])
    return gone(@collectivity) if @collectivity.discarded?

    @background_url = referrer_path || collectivity_path(@collectivity)
  end

  def remove_all
    @collectivities = Collectivity.kept.strict_loading
    @collectivities = filter_collection(@collectivities)
    @background_url = referrer_path || collectivities_path(**selection_params)
  end

  def create
    @collectivity = Collectivity.new(collectivity_params)
    @collectivity.save

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || collectivities_path }
  end

  def update
    @collectivity = Collectivity.find(params[:id])
    return gone(@collectivity) if @collectivity.discarded?

    @collectivity.update(collectivity_params)

    respond_with @collectivity,
      flash: true,
      location: -> { redirect_path || collectivities_path }
  end

  def destroy
    @collectivity = Collectivity.find(params[:id])
    @collectivity.discard

    respond_with @collectivity,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: -> { redirect_path || collectivities_path }
  end

  def undiscard
    @collectivity = Collectivity.find(params[:id])
    @collectivity.undiscard

    respond_with @collectivity,
      flash: true,
      location: redirect_path || referrer_path || collectivities_path
  end

  def destroy_all
    @collectivities = Collectivity.kept.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_discard_all

    respond_with @collectivities,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || collectivities_path
  end

  def undiscard_all
    @collectivities = Collectivity.discarded.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.quickly_undiscard_all

    respond_with @collectivities,
      flash: true,
      location: redirect_path || referrer_path || collectivities_path
  end

  private

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
