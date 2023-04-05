# frozen_string_literal: true

class ServicesController < ApplicationController
  respond_to :html

  before_action :set_service,                only: %i[show edit update remove destroy undiscard]
  before_action :set_background_content_url, only: %i[new edit remove]

  def index
    @services = Service.kept.strict_loading
    @services, @pagy = index_collection(@services)
  end

  def show; end

  def new
    @service = Service.new(service_params)
  end

  def edit; end
  def remove; end

  def create
    @service = Service.new(service_params)

    if @service.save
      @location = service_path(@service)
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @service.update(service_params)
      @location = url_from(params[:redirect]) || services_path
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.discard

    @location = url_from(params[:redirect]) || services_path
    @notice   = translate(".success").merge(
      actions: {
        label:  "Annuler",
        url:    undiscard_service_path(@service),
        method: :patch,
        inputs: { redirect: @location }
      }
    )

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def remove_all
    @services = Service.kept.strict_loading
    @services = filter_collection(@services)

    @background_content_url = services_path(ids: params[:ids], **index_params)
    @return_location        = services_path(**index_params)
  end

  def destroy_all
    @services = Service.kept.strict_loading
    @services = filter_collection(@services)
    @services.update_all(discarded_at: Time.current)

    @location   = services_path if params[:ids] == "all"
    @location ||= services_path(**index_params)
    @notice     = translate(".success").merge(
      actions: {
        label:  "Annuler",
        url:    undiscard_all_services_path,
        method: :patch,
        inputs: {
          ids:      params[:ids],
          redirect: @location,
          **index_params
        }
      }
    )

    respond_to do |format|
      format.turbo_stream  { redirect_to @location, notice: @notice }
      format.html          { redirect_to @location, notice: @notice }
    end
  end

  def undiscard
    @service.undiscard

    @location = url_from(params[:redirect]) || services_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def undiscard_all
    @services = Service.discarded.strict_loading
    @services = filter_collection(@services)
    @services.update_all(discarded_at: nil)

    @location = url_from(params[:redirect]) || services_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def set_background_content_url
    default = services_path
    default = service_path(@service) if @service&.persisted?

    @background_content_url = url_from(params[:content]) || default
  end

  def service_params
    input      = params.fetch(:service, {})
    ddfip_name = input.delete(:ddfip_name)

    input[:ddfip_id] = DDFIP.kept.search(name: ddfip_name).pick(:id) if ddfip_name.present?

    input.permit(:ddfip_id, :name, :action)
  end

  def index_params
    params
      .slice(:search, :order, :page)
      .permit(:search, :order, :page)
  end
end
