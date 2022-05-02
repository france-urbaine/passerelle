# frozen_string_literal: true

class DepartementsController < ApplicationController
  respond_to :html
  before_action :accept_autocomplete, only: :index
  before_action :set_departement, only: %i[show edit update]

  def index
    @departements = Departement.strict_loading

    respond_to do |format|
      format.html.any do
        @departements = search(@departements)
        @departements = order(@departements)
        @pagy, @departements = pagy(@departements)
      end

      format.html.autocomplete do
        @departements = autocomplete(@departements)
        render layout: false
      end
    end
  end

  def show; end
  def edit; end

  def update
    if @departement.update(departement_params)
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to params.fetch(:back, :departements), notice: t(".success")
        end
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
          .permit(:name, :code_departement, :code_region)
  end
end
