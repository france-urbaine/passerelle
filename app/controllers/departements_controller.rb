# frozen_string_literal: true

class DepartementsController < ApplicationController
  respond_to :html
  before_action :set_departement, only: %i[show edit update]

  def index
    @departements = Departement.strict_loading
    @departements, @pagy = index_collection(@departements)

    respond_to do |format|
      format.html.any
      format.html.autocomplete { render layout: false }
    end
  end

  def show; end

  def edit
    @background_content_url = url_from(params[:content]) || departement_path(@departement)
  end

  def update
    if @departement.update(departement_params)
      @location = url_from(params[:redirect]) || departements_path
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
