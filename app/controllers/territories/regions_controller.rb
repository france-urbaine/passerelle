# frozen_string_literal: true

module Territories
  class RegionsController < ApplicationController
    before_action :authorize!

    def index
      @regions = Region.strict_loading
      @regions, @pagy = index_collection(@regions)

      respond_with @regions do |format|
        format.html.autocomplete { render layout: false }
      end
    end

    def show
      @region = Region.find(params[:id])
    end

    def edit
      @region = Region.find(params[:id])
      @referrer_path = referrer_path || territories_region_path(@region)
    end

    def update
      @region = Region.find(params[:id])
      @region.update(region_params)

      respond_with @region,
        flash: true,
        location: -> { redirect_path || territories_regions_path }
    end

    private

    def region_params
      authorized(params.fetch(:region, {}))
    end
  end
end
