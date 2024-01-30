# frozen_string_literal: true

module Reports
  class AssignmentsController < ApplicationController
    before_action { authorize! Report, with: Reports::AssignmentPolicy }

    def edit
      @report = find_and_authorize_report
      @referrer_path = referrer_path || report_path(@report)
    end

    def update
      @report = find_and_authorize_report
      @report.assign_attributes(report_params)
      @report.assign! || @report.save

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

      authorize! report, with: Reports::AssignmentPolicy
      only_kept! report

      report
    end

    def report_params
      input = params.fetch(:report, {})

      authorized input, with: Reports::AssignmentPolicy
    end
  end
end
