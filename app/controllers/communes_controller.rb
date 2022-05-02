# frozen_string_literal: true

class CommunesController < ApplicationController
  respond_to :html
  before_action :accept_autocomplete, only: :index
  before_action :set_commune, only: %i[show edit update]

  def index
    @communes = Commune.strict_loading

    respond_to do |format|
      format.html.any do
        @communes = search(@communes)
        @communes = order(@communes)
        @pagy, @communes = pagy(@communes)
      end

      format.html.autocomplete do
        @communes = autocomplete(@communes)
        render layout: false
      end
    end
  end

  def show; end
  def edit; end

  def update
    if @commune.update(commune_params)
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to params.fetch(:back, :communes), notice: t(".success")
        end
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
          .permit(:name, :code_insee, :code_departement, :siren_epci)
  end
end
