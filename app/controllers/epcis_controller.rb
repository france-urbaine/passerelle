# frozen_string_literal: true

class EpcisController < ApplicationController
  respond_to :html
  before_action :set_epci, only: %i[show edit update]

  def index
    @epcis = EPCI.all
    @epcis = search(@epcis)
    @epcis = order(@epcis)
    @pagy, @epcis = pagy(@epcis)
  end

  def show; end
  def edit; end

  def update
    if @epci.update(epci_params)
      flash[:success] = t("flash.epcis.update.success")
      redirect_to epci_path(@epci)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_epci
    @epci = EPCI.find(params[:id])
    @epci.strict_loading!(false)
  end

  def epci_params
    params
      .fetch(:epci, {})
      .permit(:name, :siren, :code_departement)
  end
end
