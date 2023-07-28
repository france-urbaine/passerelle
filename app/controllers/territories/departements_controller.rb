# frozen_string_literal: true

module Territories
  class DepartementsController < ApplicationController
    before_action :authorize!

    def index
      @departements = Departement.strict_loading
      @departements, @pagy = index_collection(@departements)

      respond_with @departements do |format|
        format.html.autocomplete { render layout: false }
        format.html.any do
          @departements = @departements.preload(:region)
        end
      end
    end

    def show
      @departement = Departement.find(params[:id])
    end

    def edit
      @departement = Departement.find(params[:id])
      @referrer_path = referrer_path || territories_departement_path(@departement)
    end

    def update
      @departement = Departement.find(params[:id])
      @departement.update(departement_params)

      respond_with @departement,
        flash: true,
        location: -> { redirect_path || territories_departements_path }
    end

    private

    def departement_params
      authorized(params.fetch(:departement, {}))
    end
  end
end
