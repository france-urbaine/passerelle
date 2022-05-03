# frozen_string_literal: true

class TerritoriesUpdatesController < ApplicationController
  respond_to :html

  DEFAULT_COMMUNES_PATH = "https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-22.zip"
  DEFAULT_EPCIS_PATH    = "https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2022.zip"

  def show
    @territories_update = TerritoriesUpdate.new(
      communes_url: DEFAULT_COMMUNES_PATH,
      epcis_url:    DEFAULT_EPCIS_PATH
    )
  end

  def create
    @territories_update = TerritoriesUpdate.new(update_params)

    if @territories_update.valid?
      @territories_update.perform_later

      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to params.fetch(:back, :communes), notice: t(".success")
        end
      end
    else
      render :show, status: :unprocessable_entity
    end
  end

  protected

  def update_params
    params.fetch(:territories_update, {})
          .permit(:communes_url, :epcis_url)
  end
end
