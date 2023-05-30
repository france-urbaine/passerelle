# frozen_string_literal: true

module Offices
  class CommunesController < ApplicationController
    before_action :authorize!
    before_action :find_and_authorize_office
    before_action :build_and_authorize_communes_scope, except: %i[edit_all update_all]
    before_action :find_and_authorize_commune,         only: %i[remove destroy]

    def index
      return not_implemented if autocomplete_request?
      return redirect_to(@office, status: :see_other) unless turbo_frame_request?

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

    def find_and_authorize_office
      @office = Office.find(params[:office_id])

      authorize! @office, to: :show?
      only_kept! @office
      only_kept! @office.ddfip
    end

    def build_and_authorize_communes_scope
      @communes = @office.communes
      @communes = authorized(@communes)
    end

    def find_and_authorize_commune
      @commune = Commune.find(params[:id])

      authorize! @commune
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
