# frozen_string_literal: true

class TerritoriesController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  skip_after_action  :verify_authorized, only: :index

  before_action { authorize! with: TerritoriesPolicy }

  def index
    if autocomplete_request?
      @territories = merge_autocomplete_collections(
        Region.strict_loading,
        Departement.strict_loading,
        EPCI.strict_loading,
        Commune.strict_loading
      )
    end

    respond_with @territories do |format|
      format.html.autocomplete { render layout: false }
      format.html.any          { not_acceptable }
    end
  end

  def edit
    @territories_update = TerritoriesUpdate.new.assign_default_urls
    @referrer_path = referrer_path || communes_path
  end

  def update
    @territories_update = TerritoriesUpdate.new(update_params)

    if @territories_update.valid?
      @territories_update.perform_later

      @location = url_from(params[:redirect]) || communes_path
      @notice   = t(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  protected

  def update_params
    params
      .fetch(:territories_update, {})
      .permit(:communes_url, :epcis_url)
  end
end
