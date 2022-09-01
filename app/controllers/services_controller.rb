# frozen_string_literal: true

class ServicesController < ApplicationController
  respond_to :html
  before_action :set_service, only: %i[show edit update destroy]

  def index
    @services = Service.kept.strict_loading
    @services = search(@services)
    @services = order(@services)
    @pagy, @services = pagy(@services)
  end

  def new
    @service = Service.new
  end

  def show; end
  def edit; end

  def create
    @service = Service.new(service_params)

    if @service.save
      @notice   = translate(".success")
      @location = params.fetch(:form_back, services_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @service.update(service_params)
      @notice   = translate(".success")
      @location = params.fetch(:form_back, services_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.discard

    @notice   = translate(".success")
    @location = params.fetch(:form_back, services_path)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    input      = params.fetch(:service, {})
    ddfip_name = input.delete(:ddfip_name)

    if ddfip_name.present?
      input[:ddfip_id] = DDFIP.kept.search(name: ddfip_name).pick(:id)
    end

    input.permit(:ddfip_id, :name, :action)
  end
end
