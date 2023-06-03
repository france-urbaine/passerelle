# frozen_string_literal: true

class DDFIPsController < ApplicationController
  before_action :authorize!
  before_action :build_ddfips_scope
  before_action :authorize_ddfips_scope
  before_action :build_ddfip,     only: %i[new create]
  before_action :find_ddfip,      only: %i[show edit remove update destroy undiscard]
  before_action :authorize_ddfip, only: %i[show edit remove update destroy undiscard]

  def index
    @ddfips = @ddfips.kept.strict_loading
    @ddfips, @pagy = index_collection(@ddfips)

    respond_with @ddfips do |format|
      format.html.autocomplete { render layout: false }
    end
  end

  def show
    only_kept! @ddfip
  end

  def new
    @background_url = referrer_path || ddfips_path
  end

  def create
    @ddfip.assign_attributes(ddfip_params)
    @ddfip.save

    respond_with @ddfip,
      flash: true,
      location: -> { redirect_path || ddfips_path }
  end

  def edit
    only_kept! @ddfip

    @background_url = referrer_path || ddfip_path(@ddfip)
  end

  def update
    only_kept! @ddfip
    @ddfip.update(ddfip_params)

    respond_with @ddfip,
      flash: true,
      location: -> { redirect_path || ddfips_path }
  end

  def remove
    only_kept! @ddfip
    @background_url = referrer_path || ddfip_path(@ddfip)
  end

  def destroy
    @ddfip.discard

    respond_with @ddfip,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || ddfips_path
  end

  def undiscard
    @ddfip.undiscard

    respond_with @ddfip,
      flash: true,
      location: redirect_path || referrer_path || ddfips_path
  end

  def remove_all
    @ddfips = @ddfips.kept.strict_loading
    @ddfips = filter_collection(@ddfips)

    @background_url = referrer_path || ddfips_path(**selection_params)
  end

  def destroy_all
    @ddfips = @ddfips.kept.strict_loading
    @ddfips = filter_collection(@ddfips)
    @ddfips.quickly_discard_all

    respond_with @ddfips,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || ddfips_path
  end

  def undiscard_all
    @ddfips = @ddfips.discarded.strict_loading
    @ddfips = filter_collection(@ddfips)
    @ddfips.quickly_undiscard_all

    respond_with @ddfips,
      flash: true,
      location: redirect_path || referrer_path || ddfips_path
  end

  private

  def build_ddfips_scope
    @ddfips = DDFIP.all
  end

  def authorize_ddfips_scope
    @ddfips = authorized(@ddfips)
  end

  def build_ddfip
    @ddfip = @ddfips.build
  end

  def find_ddfip
    @ddfip = DDFIP.find(params[:id])
  end

  def authorize_ddfip
    authorize! @ddfip
  end

  def ddfip_params
    authorized(params.fetch(:ddfip, {}))
  end
end
