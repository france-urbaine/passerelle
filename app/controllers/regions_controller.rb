# frozen_string_literal: true

class RegionsController < ApplicationController
  respond_to :html
  before_action :set_region, only: %i[show edit update]

  def index
    @regions = Region.strict_loading
    @regions = search(@regions)
    @regions = order(@regions)

    if request_variant == "autocomplete"
      @regions = @regions.limit(50)
      render layout: false, variant: :autocomplete
    else
      @pagy, @regions = pagy(@regions)
    end
  end

  def show; end
  def edit; end

  def update
    if @region.update(region_params)
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to params.fetch(:back, :regions), notice: t(".success")
        end
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
    params.fetch(:region, {})
          .permit(:name, :code_region)
  end
end
