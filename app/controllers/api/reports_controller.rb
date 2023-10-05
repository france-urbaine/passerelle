# frozen_string_literal: true

module API
  class ReportsController < ApplicationController
    before_action :authorize!
    before_action :find_transmission

    def create
      build_report

      service = API::Reports::UpdateService.new(@report)
      result  = service.save

      respond_with result
    end

    private

    def reports_params
      authorized(params.require(:report))
    end

    def find_transmission
      @transmission = current_publisher.transmissions.find(params[:transmission_id])

      authorize! @transmission, to: :fill?
    end

    def build_report
      @report = Report.new(reports_params)
      @report.collectivity = @transmission.collectivity
      @report.completed_at = Time.zone.now
      @report.transmission = @transmission
      @report.publisher    = current_publisher
    end
  end
end