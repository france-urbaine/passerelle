# frozen_string_literal: true

module Offices
  class CommunesController < ApplicationController
    respond_to :html

    before_action do
      office = Office.find(params[:office_id])

      next gone(office) if office.discarded?
      next gone(office.ddfip) if office.ddfip.discarded?

      @office = office
      @communes_scope = office.communes
    end

    def index
      return not_implemented if autocomplete_request?
      return redirect_to(office_path(@office), status: :see_other) if @office && !turbo_frame_request?

      @communes = @communes_scope.strict_loading
      @communes, @pagy = index_collection(@communes, nested: @office)
    end

    def remove
      @commune = @communes_scope.find(params[:id])
      return gone(@commune) if @commune.discarded?

      @background_url = referrer_path || office_path(@office)
    end

    def edit_all
      @office_communes_form = OfficeCommunesForm.new(@office)
      @background_url = referrer_path || office_path(@office)
    end

    def remove_all
      @communes = @communes_scope.strict_loading
      @communes = filter_collection(@communes)
      @background_url = referrer_path || office_path(@office)
    end

    def destroy
      @commune = @communes_scope.find(params[:id])
      @office.communes.destroy(@commune)

      respond_with @commune,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    def update_all
      @office_communes_updater = OfficeCommunesUpdater.new(@office)
      @office_communes_updater.update(commune_codes_params)

      respond_with @office_communes_updater,
        flash: true,
        location: -> { redirect_path || office_path(@office) }
    end

    def destroy_all
      @communes = @communes_scope.strict_loading
      @communes = filter_collection(@communes)
      @office.communes.destroy(@communes)

      respond_with @communes,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    private

    def commune_codes_params
      params
        .fetch(:office_communes, {})
        .slice(:commune_codes)
        .permit(commune_codes: [])
        .fetch(:commune_codes, [])
    end
  end
end
