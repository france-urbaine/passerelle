# frozen_string_literal: true

class DdfipsController < ApplicationController
  respond_to :html

  def index
    @ddfips = DDFIP.kept.strict_loading
    @ddfips, @pagy = index_collection(@ddfips)

    respond_with @ddfips do |format|
      format.html.autocomplete { render layout: false }
    end
  end

  def show
    @ddfip = DDFIP.find(params[:id])
    gone if @ddfip.discarded?
  end

  def new
    @ddfip = DDFIP.new(ddfip_params)
    @background_url = referrer_path || ddfips_path
  end

  def edit
    @ddfip = DDFIP.find(params[:id])
    return gone if @ddfip.discarded?

    @background_url = referrer_path || ddfip_path(@ddfip)
  end

  def remove
    @ddfip = DDFIP.find(params[:id])
    return gone if @ddfip.discarded?

    @background_url = referrer_path || ddfip_path(@ddfip)
  end

  def remove_all
    @ddfips = DDFIP.kept.strict_loading
    @ddfips = filter_collection(@ddfips)
    @background_url = referrer_path || ddfips_path(**selection_params)
  end

  def create
    @ddfip = DDFIP.new(ddfip_params)
    @ddfip.save

    respond_with @ddfip,
      flash: true,
      location: -> { redirect_path || referrer_path || ddfips_path }
  end

  def update
    @ddfip = DDFIP.find(params[:id])
    return gone if @ddfip.discarded?

    @ddfip.update(ddfip_params)

    respond_with @ddfip,
      flash: true,
      location: -> { redirect_path || referrer_path || ddfips_path }
  end

  def destroy
    @ddfip = DDFIP.find(params[:id])
    @ddfip.discard

    respond_with @ddfip,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || ddfips_path
  end

  def undiscard
    @ddfip = DDFIP.find(params[:id])
    @ddfip.undiscard

    respond_with @ddfip,
      flash: true,
      location: redirect_path || referrer_path || ddfips_path
  end

  def destroy_all
    @ddfips = DDFIP.kept.strict_loading
    @ddfips = filter_collection(@ddfips)
    @ddfips.dispose_all

    respond_with @ddfips,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || ddfips_path(**selection_params.except(:ids))
  end

  def undiscard_all
    @ddfips = DDFIP.discarded.strict_loading
    @ddfips = filter_collection(@ddfips)
    @ddfips.undispose_all

    respond_with @ddfips,
      flash: true,
      location: redirect_path || ddfips_path
  end

  private

  def ddfip_params
    params
      .fetch(:ddfip, {})
      .permit(:name, :code_departement)
  end
end
