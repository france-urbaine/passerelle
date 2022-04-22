# frozen_string_literal: true

class RegionsController < ApplicationController
  respond_to :html
  before_action :set_region, only: %i[show edit update]

  def index
    @regions = Region.strict_loading
    @regions = search(@regions)
    @regions = order(@regions)
    @pagy, @regions = pagy(@regions)
  end

  def show; end
  def edit; end

  def update
    if @region.update(region_params)
      path = params.fetch(:back, regions_path)
      redirect_to path, notice: t(".success")
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
      .permit(:name, :code_region)
  end
end
