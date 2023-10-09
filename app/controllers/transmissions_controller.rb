# frozen_string_literal: true

class TransmissionsController < ApplicationController
  before_action :authorize!

  def show
    @transmission = find_or_initialize_transmission
    @referrer_path = referrer_path
  end

  def create
    @transmission  = find_or_initialize_transmission
    @reports       = build_and_authorize_scope
    @reports       = filter_collection(@reports)
    @referrer_path = referrer_path

    @service = Transmissions::CreateService.new(@transmission)
    @result  = @service.add(@reports)

    respond_to(:turbo_stream)
  end

  def destroy
    @transmission  = find_or_initialize_transmission
    @reports       = build_and_authorize_scope
    @reports       = filter_collection(@reports)
    @referrer_path = referrer_path

    @service = Transmissions::RemoveService.new(@transmission)
    @result  = @service.remove(@reports)

    respond_to(:turbo_stream)
  end

  def complete
    @transmission = find_or_initialize_transmission

    service = Transmissions::CompleteService.new(@transmission)
    result  = service.complete

    respond_with result,
      flash: true,
      location: referrer_path || reports_path
  end

  private

  def build_and_authorize_scope
    authorized(Report.preload(:package), as: :default).strict_loading
  end

  def find_or_initialize_transmission
    current_user.transmissions.find_or_create_by(
      completed_at: nil,
      collectivity: current_user.organization
    )
  end
end
