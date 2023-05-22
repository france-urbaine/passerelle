# frozen_string_literal: true

class CommunesController < ApplicationController
  def index
    @communes = Commune.strict_loading
    @communes, @pagy = index_collection(@communes, nested: @parent)

    respond_with @communes do |format|
      format.html.autocomplete { render layout: false }
    end
  end

  def show
    @commune = Commune.find(params[:id])
  end

  def edit
    @commune = Commune.find(params[:id])
    @background_url = referrer_path || commune_path(@commune)
  end

  def update
    @commune = Commune.find(params[:id])
    @commune.update(commune_params)

    respond_with @commune,
      flash: true,
      location: -> { redirect_path || communes_path }
  end

  private

  def commune_params
    params
      .fetch(:commune, {})
      .permit(:name, :code_insee, :code_departement, :siren_epci, :qualified_name)
  end
end
