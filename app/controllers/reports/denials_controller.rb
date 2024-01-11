# frozen_string_literal: true

module Reports
  class DenialsController < ApplicationController
    before_action { authorize! Report, with: Reports::DenialPolicy }

    def edit
      @report = find_and_authorize_report
      @referrer_path = referrer_path || report_path(@report)
    end

    def update
      @report = find_and_authorize_report
      @report.deny!

      respond_with @report,
        flash: true,
        location: -> { redirect_path || report_path(@report) }
    end

    def remove
      @report = find_and_authorize_report
      @referrer_path = referrer_path || report_path(@report)
      @redirect_path = @referrer_path unless @referrer_path.include?(report_path(@report))
    end

    def destroy
      @report = find_and_authorize_report
      @report.acknowledge!

      respond_with @report,
        flash: true,
        location: -> { redirect_path || report_path(@report) }
    end

    private

    def find_and_authorize_report
      report = Report.find(params[:report_id])

      authorize! report, with: Reports::DenialPolicy
      only_kept! report

      report
    end

    def report_params
      authorized(params.fetch(:report, {}))
    end

    def implicit_authorization_target
      :denial
    end
  end
end
