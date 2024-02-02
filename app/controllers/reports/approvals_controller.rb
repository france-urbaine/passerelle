# frozen_string_literal: true

module Reports
  class ApprovalsController < ApplicationController
    before_action { authorize! Report, with: Reports::ApprovalPolicy }

    def edit
      @report = find_and_authorize_report
      redirect_to report_path(@report), status: :see_other
    end

    def update
      @report = find_and_authorize_report
      service = Reports::StateService.new(@report)
      result  = service.approve

      respond_with result,
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
      service = Reports::StateService.new(@report)
      result  = service.unapprove

      respond_with result,
        flash: true,
        location: redirect_path || report_path(@report)
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
