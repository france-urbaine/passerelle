# frozen_string_literal: true

class CollectivitiesController < ApplicationController
  respond_to :html
  before_action :set_collectivity, only: %i[show edit update destroy]

  def index
    @collectivities = Collectivity.kept.strict_loading
    @collectivities = search(@collectivities)
    @collectivities = order(@collectivities)
    @pagy, @collectivities = pagy(@collectivities)
  end

  def new
    @collectivity = Collectivity.new
  end

  def show; end
  def edit; end

  def create
    @collectivity = Collectivity.new(collectivity_params)

    if @collectivity.save
      @notice   = t(".success")
      @location = params.fetch(:form_back, collectivities_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collectivity.update(collectivity_params)
      @notice   = t(".success")
      @location = params.fetch(:form_back, collectivities_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collectivity.discard

    @notice   = t(".success")
    @location = params.fetch(:form_back, collectivities_path)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_collectivity
    @collectivity = Collectivity.find(params[:id])
  end

  def collectivity_params
    input          = params.fetch(:collectivity, {})
    territory_data = input.delete(:territory_data)

    if territory_data.present?
      territory_data = JSON.parse(territory_data)
      input[:territory_type] = territory_data["type"]
      input[:territory_id]   = territory_data["id"]
    end

    input.permit(
      :territory_type, :territory_id, :publisher_id, :name, :siren,
      :contact_first_name, :contact_last_name, :contact_email, :contact_phone
    )
  end
end
