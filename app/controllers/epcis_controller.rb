# frozen_string_literal: true

class EpcisController < ApplicationController
  respond_to :html
  before_action :accept_autocomplete, only: :index
  before_action :set_epci, only: %i[show edit update]

  def index
    @epcis = EPCI.strict_loading

    respond_to do |format|
      format.html.any do
        @epcis = search(@epcis)
        @epcis = order(@epcis)
        @pagy, @epcis = pagy(@epcis)
      end

      format.html.autocomplete do
        @epcis = autocomplete(@epcis)
        render layout: false
      end
    end
  end

  def show; end
  def edit; end

  def update
    if @epci.update(epci_params)
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to params.fetch(:back, :epcis), notice: t(".success")
        end
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
