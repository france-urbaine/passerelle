# frozen_string_literal: true

class DDFIPsController < ApplicationController
  before_action :authorize!

  def index
    @ddfips = build_and_authorize_scope
    @ddfips, @pagy = index_collection(@ddfips)

    respond_with @ddfips do |format|
      format.html.autocomplete { render layout: false }
    end
  end

  def show
    @ddfip = find_and_authorize_ddfip
  end

  def new
    @ddfip = build_ddfip
    @background_url = referrer_path || ddfips_path
  end

  def create
    @ddfip = build_ddfip(ddfip_params)
    @ddfip.save

    respond_with @ddfip,
      flash: true,
      location: -> { redirect_path || ddfips_path }
  end

  def edit
    @ddfip = find_and_authorize_ddfip
    @background_url = referrer_path || ddfip_path(@ddfip)
  end

  def update
    @ddfip = find_and_authorize_ddfip
    @ddfip.update(ddfip_params)

    respond_with @ddfip,
      flash: true,
      location: -> { redirect_path || ddfips_path }
  end

  def remove
    @ddfip = find_and_authorize_ddfip
    @background_url = referrer_path || ddfip_path(@ddfip)
  end

  def destroy
    @ddfip = find_and_authorize_ddfip(allow_discarded: true)
    @ddfip.discard

    respond_with @ddfip,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || ddfips_path
  end

  def undiscard
    @ddfip = find_and_authorize_ddfip(allow_discarded: true)
    @ddfip.undiscard

    respond_with @ddfip,
      flash: true,
      location: redirect_path || referrer_path || ddfips_path
  end

  def remove_all
    @ddfips = build_and_authorize_scope
    @ddfips = filter_collection(@ddfips)
    @background_url = referrer_path || ddfips_path(**selection_params)
  end

  def destroy_all
    @ddfips = build_and_authorize_scope(as: :destroyable)
    @ddfips = filter_collection(@ddfips)
    @ddfips.quickly_discard_all

    respond_with @ddfips,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || ddfips_path
  end

  def undiscard_all
    @ddfips = build_and_authorize_scope(as: :undiscardable)
    @ddfips = filter_collection(@ddfips)
    @ddfips.quickly_undiscard_all

    respond_with @ddfips,
      flash: true,
      location: redirect_path || referrer_path || ddfips_path
  end

  private

  def build_and_authorize_scope(as: :default)
    authorized(DDFIP.all, as:).strict_loading
  end

  def build_ddfip(...)
    build_and_authorize_scope.build(...)
  end

  def find_and_authorize_ddfip(allow_discarded: false)
    ddfip = DDFIP.find(params[:id])

    authorize! ddfip
    only_kept! ddfip unless allow_discarded

    ddfip
  end

  def ddfip_params
    authorized(params.fetch(:ddfip, {}))
  end
end
