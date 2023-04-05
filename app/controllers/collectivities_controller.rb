# frozen_string_literal: true

class CollectivitiesController < ApplicationController
  respond_to :html

  before_action :set_collectivity,           only: %i[show edit update remove destroy undiscard]
  before_action :set_background_content_url, only: %i[new edit remove]

  def index
    @collectivities = Collectivity.kept.strict_loading
    @collectivities, @pagy = index_collection(@collectivities)
  end

  def show; end

  def new
    @collectivity = Collectivity.new(collectivity_params)
  end

  def edit; end
  def remove; end

  def create
    @collectivity = Collectivity.new(collectivity_params)

    if @collectivity.save
      @location = url_from(params[:redirect]) || collectivities_path
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collectivity.update(collectivity_params)
      @location = url_from(params[:redirect]) || collectivities_path
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collectivity.discard

    @location = url_from(params[:redirect]) || collectivities_path
    @notice   = translate(".success")
    @cancel   = FlashAction::Cancel.new(params).to_h

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html         { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def remove_all
    @collectivities = Collectivity.kept.strict_loading
    @collectivities = filter_collection(@collectivities)

    @background_content_url = collectivities_path(ids: params[:ids], **index_params)
  end

  def destroy_all
    @collectivities = Collectivity.kept.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.update_all(discarded_at: Time.current)

    @location   = collectivities_path if params[:ids] == "all"
    @location ||= collectivities_path(**index_params)
    @notice     = translate(".success")
    @cancel     = FlashAction::Cancel.new(params).to_h

    respond_to do |format|
      format.turbo_stream  { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html          { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def undiscard
    @collectivity.undiscard

    @location = url_from(params[:redirect]) || collectivities_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def undiscard_all
    @collectivities = Collectivity.discarded.strict_loading
    @collectivities = filter_collection(@collectivities)
    @collectivities.update_all(discarded_at: nil)

    @location = url_from(params[:redirect]) || collectivities_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_collectivity
    @collectivity = Collectivity.find(params[:id])
  end

  def set_background_content_url
    default = collectivities_path
    default = collectivity_path(@collectivity) if @collectivity&.persisted?

    @background_content_url = url_from(params[:content]) || default
  end

  def collectivity_params
    input          = params.fetch(:collectivity, {})
    territory_data = input.delete(:territory_data)
    territory_code = input.delete(:territory_code)

    if territory_data.present?
      territory_data = JSON.parse(territory_data)
      input[:territory_type] = territory_data["type"]
      input[:territory_id]   = territory_data["id"]
    end

    if territory_code.present?
      input[:territory_id] =
        case input[:territory_type]
        when "Commune"     then Commune.where(code_insee: territory_code).pick(:id)
        when "EPCI"        then EPCI.where(siren: territory_code).pick(:id)
        when "Departement" then Departement.where(code_departement: territory_code).pick(:id)
        when "Region"      then Region.where(code_region: territory_code).pick(:id)
        end
    end

    input.permit(
      :territory_type, :territory_id, :publisher_id, :name, :siren,
      :contact_first_name, :contact_last_name, :contact_email, :contact_phone
    )
  end

  def index_params
    params
      .slice(:search, :order, :page)
      .permit(:search, :order, :page)
  end
end
