# frozen_string_literal: true

class DepartementsController < ApplicationController
  respond_to :html
  before_action :set_departement, only: %i[show edit update]

  def index
    @departements = Departement.strict_loading

    if autocomplete_request?
      @departements = autocomplete(@departements)
    else
      @departements = search(@departements)
      @departements = order(@departements)
      @pagy, @departements = pagy(@departements)
    end

    respond_to do |format|
      format.html.any
      format.html.autocomplete { render layout: false }
    end
  end

  def show; end
  def edit; end

  def update
    if @departement.update(departement_params)
      @notice   = t(".success")
      @location = params.fetch(:form_back, departements_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
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
    params.fetch(:departement, {})
          .permit(:name, :code_departement, :code_region, :qualified_name)
  end
end
