# frozen_string_literal: true

class TransmissionsController < ApplicationController
  before_action :authorize!

  def show
    @transmission = find_or_initialize_transmission
    @referrer_path = referrer_path
  end

  def create
    @transmission = find_or_initialize_transmission

    @reports                 = find_and_authorize_reports
    service                  = Reports::CheckTransmissibilityService.new(@reports)
    @transmissible_reports   = service.transmissibles
    @intransmissible_reports = service.intransmissibles
    @referrer_path           = referrer_path

    @transmission.reports << @transmissible_reports
  end

  def complete
    @transmission = find_or_initialize_transmission

    service = Transmissions::CompleteService.new(@transmission)
    result  = service.save

    respond_with result,
      flash: true,
      location: referrer_path || reports_path
  end

  private

  def find_or_initialize_transmission
    current_user.transmissions.find_or_create_by(
      completed_at: nil,
      collectivity: current_user.organization
    )
  end

  def find_and_authorize_reports
    reports = Report.where(id: params[:ids])

    authorized(reports)
  end
end
