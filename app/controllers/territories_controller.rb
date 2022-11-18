# frozen_string_literal: true

class TerritoriesController < ApplicationController
  respond_to :html

  DEFAULT_COMMUNES_PATH = "https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-22.zip"
  DEFAULT_EPCIS_PATH    = "https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2022.zip"

  def index
    if autocomplete_request?
      @territories  = autocomplete_territories(Region)
      @territories += autocomplete_territories(Departement, @territories)
      @territories += autocomplete_territories(EPCI, @territories)
      @territories += autocomplete_territories(Commune, @territories)
    end

    respond_to do |format|
      format.html.autocomplete { render layout: false }
      format.html.any          { not_acceptable }
    end
  end

  def edit
    @territories_update = TerritoriesUpdate.new(
      communes_url: DEFAULT_COMMUNES_PATH,
      epcis_url:    DEFAULT_EPCIS_PATH
    )

    @content_location = safe_location_param(:content, communes_path)
  end

  def update
    @territories_update = TerritoriesUpdate.new(update_params)

    if @territories_update.valid?
      @territories_update.perform_later

      @location = safe_location_param(:redirect, communes_path)
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  def update_params
    params
      .fetch(:territories_update, {})
      .permit(:communes_url, :epcis_url)
  end

  def autocomplete_territories(model, territories = [])
    return territories if territories.size >= 50

    input    = params[:q]
    relation = model.strict_loading
    relation.search(name: input)
      .order_by_score(input)
      .order(relation.implicit_order_column)
      .limit(50 - territories.size)
      .to_a
  end
end
