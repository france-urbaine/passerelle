# frozen_string_literal: true

class CommunesController < ApplicationController
  respond_to :html
  before_action :set_commune, only: %i[show edit update]

  def index
    @communes = Commune.strict_loading
    @communes = search(@communes)
    @communes = order(@communes)
    @pagy, @communes = pagy(@communes)
  end

  def show; end
  def edit; end

  def update
    if @commune.update(commune_params)
      path   = params.fetch(:back, communes_path)
      notice = t(".success")

      respond_to do |format|
        format.turbo_stream { flash.now.notice = notice }
        format.html         { redirect_to path, notice: notice }
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
    params
      .fetch(:commune, {})
      .permit(:name, :code_insee, :code_departement, :siren_epci)
  end
end
