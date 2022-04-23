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
      path   = params.fetch(:back, departements_path)
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

  def set_departement
    @departement = Departement.find(params[:id])
  end

  def departement_params
    params
      .fetch(:departement, {})
      .permit(:name, :code_departement, :code_region)
  end
end
