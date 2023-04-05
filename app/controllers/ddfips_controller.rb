# frozen_string_literal: true

class DdfipsController < ApplicationController
  respond_to :html

  before_action :set_ddfip,                  only: %i[show edit update remove destroy undiscard]
  before_action :set_background_content_url, only: %i[new edit remove]

  def index
    @ddfips = DDFIP.kept.strict_loading
    @ddfips, @pagy = index_collection(@ddfips)

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
      @location = url_from(params[:redirect]) || ddfips_path
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

    @location = url_from(params[:redirect]) || ddfips_path
    @notice   = translate(".success")
    @cancel   = FlashAction::Cancel.new(params).to_h

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html         { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def remove_all
    @ddfips = DDFIP.kept.strict_loading
    @ddfips = filter_collection(@ddfips)

    @background_content_url = ddfips_path(ids: params[:ids], **index_params)
    @return_location        = ddfips_path(**index_params)
  end

  def destroy_all
    @ddfips = DDFIP.kept.strict_loading
    @ddfips = filter_collection(@ddfips)
    @ddfips.update_all(discarded_at: Time.current)

    @location   = ddfips_path if params[:ids] == "all"
    @location ||= ddfips_path(**index_params)
    @notice     = translate(".success")
    @cancel     = FlashAction::Cancel.new(params).to_h

    respond_to do |format|
      format.turbo_stream  { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html          { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def undiscard
    @ddfip.undiscard

    @location = url_from(params[:redirect]) || ddfips_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def undiscard_all
    @ddfips = DDFIP.discarded.strict_loading
    @ddfips = filter_collection(@ddfips)
    @ddfips.update_all(discarded_at: nil)

    @location = url_from(params[:redirect]) || ddfips_path
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

  def set_background_content_url
    default = ddfips_path
    default = ddfip_path(@ddfip) if @ddfip&.persisted?

    @background_content_url = url_from(params[:content]) || default
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
