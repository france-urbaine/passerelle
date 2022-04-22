# frozen_string_literal: true

class EpcisController < ApplicationController
  respond_to :html
  before_action :set_epci, only: %i[show edit update]

  def index
    @epcis = EPCI.strict_loading
    @epcis = search(@epcis)
    @epcis = order(@epcis)
    @pagy, @epcis = pagy(@epcis)
  end

  def show; end
  def edit; end

  def update
    if @epci.update(epci_params)
      path = params.fetch(:back, epcis_path)
      redirect_to path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_epci
    @epci = EPCI.find(params[:id])
  end

  def epci_params
    params
      .fetch(:epci, {})
      .permit(:name, :siren, :code_departement)
  end
end
