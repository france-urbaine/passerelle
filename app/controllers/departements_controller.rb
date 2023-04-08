# frozen_string_literal: true

class DepartementsController < ApplicationController
  respond_to :html

  def index
    @departements = Departement.strict_loading
    @departements, @pagy = index_collection(@departements)

    respond_with @departements do |format|
      format.html.autocomplete { render layout: false }
    end
  end

  def show
    @departement = Departement.find(params[:id])
  end

  def edit
    @departement = Departement.find(params[:id])
    @background_url = referrer_path || departement_path(@departement)
  end

  def update
    @departement = Departement.find(params[:id])
    @departement.update(departement_params)

    @background_url = referrer_path || departement_path(@departement) if @departement.errors.any?

    respond_with @departement,
      flash: true,
      location: -> { redirect_path || departements_path }
  end

  private

  def departement_params
    params
      .fetch(:departement, {})
      .permit(:name, :code_departement, :code_region, :qualified_name)
  end
end
