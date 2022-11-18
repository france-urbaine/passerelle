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

  def edit
    @content_location = safe_location_param(:content, departement_path(@departement))
  end

  def update
    if @departement.update(departement_params)
      @location = safe_location_param(:redirect, departements_path)
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

  def set_departement
    @departement = Departement.find(params[:id])
  end

  def departement_params
    params
      .fetch(:departement, {})
      .permit(:name, :code_departement, :code_region, :qualified_name)
  end
end
