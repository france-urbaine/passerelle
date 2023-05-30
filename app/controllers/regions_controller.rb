# frozen_string_literal: true

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
    @background_url = referrer_path || region_path(@region)
  end

  def update
    @region = Region.find(params[:id])
    @region.update(region_params)

    respond_with @region,
      flash: true,
      location: -> { redirect_path || regions_path }
  end

  private

  def region_params
    params
      .fetch(:region, {})
      .permit(:name, :code_region, :qualified_name)
  end
end
