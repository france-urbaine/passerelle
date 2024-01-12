# frozen_string_literal: true

module Reports
  class RejectionsController < ApplicationController
    before_action { authorize! Report, with: Reports::ApprovalPolicy }

    def show
      @report = find_and_authorize_report
      redirect_to report_path(@report), status: :see_other
    end

    def update
      @report = find_and_authorize_report
      @report.reject!

      respond_with @report,
        flash: true,
        location: -> { redirect_path || report_path(@report) }
    end

    private

    def find_and_authorize_report
      report = Report.find(params[:report_id])

      authorize! report, with: Reports::ApprovalPolicy
      only_kept! report

      report
    end
  end
end
