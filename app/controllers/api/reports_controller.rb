# frozen_string_literal: true

module API
  class ReportsController < ApplicationController
    before_action :authorize!
    before_action :find_transmission

    def create
      @report = @transmission.reports.build
      @report.collectivity = @transmission.collectivity
      @report.publisher    = current_publisher

      API::Reports::CreateService.new(@report, reports_params).save

      respond_with @report
    end

    private

    def reports_params
      authorized(params.require(:report))
    end

    def find_transmission
      @transmission = current_publisher.transmissions.find(params[:transmission_id])

      authorize! @transmission, to: :fill?
    end
  end
end
