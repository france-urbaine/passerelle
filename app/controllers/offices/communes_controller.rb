# frozen_string_literal: true

module Offices
  class CommunesController < ApplicationController
    before_action :scope_communes
    before_action :find_commune, only: %i[remove destroy]

    def index
      return not_implemented if autocomplete_request?
      return redirect_to(office_path(@office), status: :see_other) if @office && !turbo_frame_request?

      @communes = @communes.strict_loading
      @communes, @pagy = index_collection(@communes, nested: @office)
    end

    def remove
      @background_url = referrer_path || office_path(@office)
    end

    def edit_all
      @office_communes_form = OfficeCommunesForm.new(@office)
      @background_url = referrer_path || office_path(@office)
    end

    def remove_all
      @communes = @communes.strict_loading
      @communes = filter_collection(@communes)

      @background_url = referrer_path || office_path(@office)
    end

    def destroy
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
      @communes = @communes.strict_loading
      @communes = filter_collection(@communes)
      @office.communes.destroy(@communes)

      respond_with @communes,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    private

    def scope_communes
      office = Office.find(params[:office_id])

      only_kept! office
      only_kept! office.ddfip

      @office = office
      @communes  = office.communes
    end

    def find_commune
      @commune = @communes.find(params[:id])
    end

    def commune_codes_params
      params
        .fetch(:office_communes, {})
        .slice(:commune_codes)
        .permit(commune_codes: [])
        .fetch(:commune_codes, [])
    end
  end
end
