# frozen_string_literal: true

class OfficeCommunesController < ApplicationController
  respond_to :html

  def edit
    @office               = Office.find(params[:office_id])
    @office_communes_form = OfficeCommunesForm.new(@office)
    @background_url       = referrer_path || office_path(@office)
  end

  def update
    @office                  = Office.find(params[:office_id])
    @office_communes_updater = OfficeCommunesUpdater.new(@office)
    @office_communes_updater.update(commune_codes_params)

    respond_with @office_communes_updater,
      flash: true,
      location: -> { redirect_path || office_path(@office) }
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
