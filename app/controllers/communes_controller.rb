# frozen_string_literal: true

class CommunesController < ApplicationController
  respond_to :html
  before_action :set_commune, only: %i[show edit update]

  def index
    @communes = Commune.strict_loading

    if autocomplete_request?
      @communes = autocomplete(@communes)
    else
      @communes = search(@communes)
      @communes = order(@communes)
      @pagy, @communes = pagy(@communes)
    end

    respond_to do |format|
      format.html.any
      format.html.autocomplete { render layout: false }
    end
  end

  def show; end

  def edit
    @content_location = safe_location_param(:content, commune_path(@commune))
  end

  def update
    if @commune.update(commune_params)
      @location = safe_location_param(:redirect, communes_path)
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_commune
    @commune = Commune.find(params[:id])
  end

  def commune_params
    params.fetch(:commune, {})
          .permit(:name, :code_insee, :code_departement, :siren_epci, :qualified_name)
  end
end
