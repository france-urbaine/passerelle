# frozen_string_literal: true

module API
  class ReportsController < ApplicationController
    before_action :authorize!

    def create
      transmission = find_and_authorize_transmission

      @report = transmission.reports.build
      @report.collectivity = transmission.collectivity
      @report.publisher    = current_publisher

      API::Reports::CreateService.new(@report, reports_params).save

      respond_with @report
    end

    private

    def find_and_authorize_transmission
      current_publisher.transmissions.find(params[:transmission_id]).tap do |transmission|
        authorize! transmission, to: :read?
        forbidden! t(".already_completed") if transmission.completed?
        authorize! transmission, to: :fill?
      end
    end

    def reports_params
      authorized(params.require(:report))
    end
  end
end