# frozen_string_literal: true

module Territories
  class CommunesController < ApplicationController
    before_action :authorize!

    def index
      @communes = Commune.strict_loading
      @communes, @pagy = index_collection(@communes)

      respond_with @communes do |format|
        format.html.autocomplete { render layout: false }
        format.html.any do
          @communes = @communes.preload(:departement, :epci)
        end
      end
    end

    def show
      @commune = Commune.find(params[:id])
    end

    def edit
      @commune = Commune.find(params[:id])
      @referrer_path = referrer_path || territories_commune_path(@commune)
    end

    def update
      @commune = Commune.find(params[:id])
      @commune.update(commune_params)

      respond_with @commune,
        flash: true,
        location: -> { redirect_path || territories_communes_path }
    end

    private

    def commune_params
      authorized(params.fetch(:commune, {}))
    end
  end
end
