# frozen_string_literal: true

class CommunesController < ApplicationController
  respond_to :html
  before_action :set_commune, only: %i[show edit update]

  def index
    @communes = Commune.all
    @communes = search(@communes)
    @communes = order(@communes)
    @pagy, @communes = pagy(@communes)
  end

  def show; end
  def edit; end

  def update
    if @commune.update(commune_params)
      flash[:success] = t("flash.communes.update.success")
      redirect_to commune_path(@commune)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_commune
    @commune = Commune.find(params[:id])
    @commune.strict_loading!(false)
  end

  def commune_params
    params
      .fetch(:commune, {})
      .permit(:name, :code_insee, :code_departement, :siren_epci)
  end
end
