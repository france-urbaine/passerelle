# frozen_string_literal: true

class ServicesCommunesController < ApplicationController
  respond_to :html
  before_action :set_service

  def edit
    @services_communes_form = ServicesCommunesForm.new(@service)
    @content_location       = safe_location_param(:content, service_path(@service))
  end

  def update
    @services_communes_form = ServicesCommunesForm.new(@service)
    codes_insee_params = params
      .fetch(:services_communes_form, {})
      .slice(:codes_insee)
      .permit(codes_insee: [])
      .fetch(:codes_insee, [])

    if @services_communes_form.update(codes_insee_params)
      @location = safe_location_param(:redirect, service_path(@service))
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_service
    @service = Service.find(params[:service_id])
  end
end
