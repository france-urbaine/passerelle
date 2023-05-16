# frozen_string_literal: true

class EPCIsController < ApplicationController
  def index
    @epcis = EPCI.strict_loading
    @epcis, @pagy = index_collection(@epcis)

    respond_with @epcis do |format|
      format.html.autocomplete { render layout: false }
    end
  end

  def show
    @epci = EPCI.find(params[:id])
  end

  def edit
    @epci = EPCI.find(params[:id])
    @background_url = referrer_path || epci_path(@epci)
  end

  def update
    @epci = EPCI.find(params[:id])
    @epci.update(epci_params)

    respond_with @epci,
      flash: true,
      location: -> { redirect_path || epcis_path }
  end

  private

  def epci_params
    params
      .fetch(:epci, {})
      .permit(:name, :siren, :code_departement)
  end
end
