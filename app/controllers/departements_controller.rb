# frozen_string_literal: true

class DepartementsController < ApplicationController
  respond_to :html
  before_action :set_departement, only: %i[show edit update]

  def index
    @departements = Departement.strict_loading
    @departements = search(@departements)
    @departements = order(@departements)
    @pagy, @departements = pagy(@departements)
  end

  def show; end
  def edit; end

  def update
    if @departement.update(departement_params)
      path = params.fetch(:back, departements_path)
      redirect_to path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_departement
    @departement = Departement.find(params[:id])
  end

  def departement_params
    params
      .fetch(:departement, {})
      .permit(:name, :code_departement, :code_region)
  end
end
