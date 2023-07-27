# frozen_string_literal: true

module Territories
  class EPCIsController < ApplicationController
    before_action :authorize!

    def index
      @epcis = EPCI.strict_loading
      @epcis, @pagy = index_collection(@epcis)

      respond_with @epcis do |format|
        format.html.autocomplete { render layout: false }
        format.html.any do
          @epcis = @epcis.preload(:departement)
        end
      end
    end

    def show
      @epci = EPCI.find(params[:id])
    end

    def edit
      @epci = EPCI.find(params[:id])
      @referrer_path = referrer_path || territories_epci_path(@epci)
    end

    def update
      @epci = EPCI.find(params[:id])
      @epci.update(epci_params)

      respond_with @epci,
        flash: true,
        location: -> { redirect_path || territories_epcis_path }
    end

    private

    def epci_params
      authorized(params.fetch(:epci, {}))
    end
  end
end
