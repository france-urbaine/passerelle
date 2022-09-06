# frozen_string_literal: true

class EpcisController < ApplicationController
  respond_to :html
  before_action :set_epci, only: %i[show edit update]

  def index
    @epcis = EPCI.strict_loading

    if autocomplete_request?
      @epcis = autocomplete(@epcis)
    else
      @epcis = search(@epcis)
      @epcis = order(@epcis)
      @pagy, @epcis = pagy(@epcis)
    end

    respond_to do |format|
      format.html.any
      format.html.autocomplete { render layout: false }
    end
  end

  def show; end

  def edit
    @content_location = safe_location_param(:content, epci_path(@epci))
  end

  def update
    if @epci.update(epci_params)
      @location = safe_location_param(:redirect, epcis_path)
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

  def set_epci
    @epci = EPCI.find(params[:id])
  end

  def epci_params
    params.fetch(:epci, {})
          .permit(:name, :siren, :code_departement)
  end
end
