# frozen_string_literal: true

class RegionsController < ApplicationController
  respond_to :html
  before_action :set_region, only: %i[show edit update]

  def index
    @regions = Region.strict_loading
    @regions, @pagy = index_collection(@regions)

    respond_to do |format|
      format.html.any
      format.html.autocomplete { render layout: false }
    end
  end

  def show; end

  def edit
    @background_content_url = url_from(params[:content]) || region_path(@region)
  end

  def update
    if @region.update(region_params)
      @location = url_from(params[:redirect]) || regions_path
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

  def set_region
    @region = Region.find(params[:id])
  end

  def region_params
    params
      .fetch(:region, {})
      .permit(:name, :code_region, :qualified_name)
  end
end
