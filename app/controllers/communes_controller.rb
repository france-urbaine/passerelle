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
  def edit; end

  def update
    if @commune.update(commune_params)
      @notice   = translate(".success")
      @location = params.fetch(:form_back, communes_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
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
