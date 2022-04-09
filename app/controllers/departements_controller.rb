# frozen_string_literal: true

class DepartementsController < ApplicationController
  respond_to :html
  before_action :set_departement, only: %i[show edit update]

  def index
    @departements = Departement.all
    @departements = search(@departements)
    @departements = order(@departements)
    @pagy, @departements = pagy(@departements)
  end

  def show; end
  def edit; end

  def update
    if @departement.update(departement_params)
      flash[:success] = t("flash.departements.update.success")
      redirect_to departement_path(@departement)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_departement
    @departement = Departement.find(params[:id])
    @departement.strict_loading!(false)
  end

  def departement_params
    params
      .fetch(:departement, {})
      .permit(:name, :code_departement, :code_region)
  end
end
