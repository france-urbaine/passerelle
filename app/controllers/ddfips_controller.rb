# frozen_string_literal: true

class DdfipsController < ApplicationController
  respond_to :html

  before_action :set_ddfip,            only: %i[show edit update remove destroy undiscard]
  before_action :set_content_location, only: %i[new edit remove]

  def index
    @ddfips = DDFIP.kept.strict_loading

    if autocomplete_request?
      @ddfips = autocomplete(@ddfips)
    else
      @ddfips = search(@ddfips)
      @ddfips = order(@ddfips)
      @pagy, @ddfips = pagy(@ddfips)
    end

    respond_to do |format|
      format.html.any
      format.html.autocomplete { render layout: false }
    end
  end

  def show; end

  def new
    @ddfip = DDFIP.new(ddfip_params)
  end

  def edit; end
  def remove; end

  def create
    @ddfip = DDFIP.new(ddfip_params)

    if @ddfip.save
      @location = ddfip_path(@ddfip)
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
    if @ddfip.update(ddfip_params)
      @location = safe_location_param(:redirect, ddfips_path)
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
    @ddfip.discard

    @location = safe_location_param(:redirect, ddfips_path)
    @notice   = translate(".success").merge(
      actions: {
        label:  "Annuler",
        url:    undiscard_ddfip_path(@ddfip),
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
    @ddfips = DDFIP.kept.strict_loading
    @ddfips = search(@ddfips)
    @ddfips = select(@ddfips)

    @content_location = ddfips_path(ids: params[:ids], **index_params)
    @return_location  = ddfips_path(**index_params)
  end

  def destroy_all
    @ddfips = DDFIP.kept.strict_loading
    @ddfips = search(@ddfips)
    @ddfips = select(@ddfips)
    @ddfips.update_all(discarded_at: Time.current)

    @location   = ddfips_path if params[:ids] == "all"
    @location ||= ddfips_path(**index_params)
    @notice     = translate(".success").merge(
      actions: {
        label:  "Annuler",
        url:    undiscard_all_ddfips_path,
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
    @ddfip.undiscard

    @location = safe_location_param(:redirect, ddfips_path)
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def undiscard_all
    @ddfips = DDFIP.discarded.strict_loading
    @ddfips = search(@ddfips)
    @ddfips = select(@ddfips)
    @ddfips.update_all(discarded_at: nil)

    @location = safe_location_param(:redirect, ddfips_path)
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_ddfip
    @ddfip = DDFIP.find(params[:id])
  end

  def set_content_location
    default = ddfips_path
    default = ddfip_path(@ddfip) if @ddfip&.persisted?

    @content_location = safe_location_param(:content, default)
  end

  def ddfip_params
    params
      .fetch(:ddfip, {})
      .permit(:name, :code_departement)
  end

  def index_params
    params
      .slice(:search, :order, :page)
      .permit(:search, :order, :page)
  end
end
