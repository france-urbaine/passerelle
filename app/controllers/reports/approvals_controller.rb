# frozen_string_literal: true

module Reports
  class ApprovalsController < ApplicationController
    before_action { authorize! Report, with: Reports::ApprovalPolicy }

    def edit
      @report = find_and_authorize_report

      # FYI: If we implement the edit template, we'll have to
      # uncomment to following line, and remove the redirection
      #
      #   @referrer_path = referrer_path || report_path(@report)
      #
      redirect_to report_path(@report), status: :see_other
    end

    def update
      @report = find_and_authorize_report
      service = Reports::StateService.new(@report)
      result  = service.approve

      # FYI: If we implement the edit template, we'll have to
      # replace referrer_path by redirect_path
      #
      respond_with result,
        flash: true,
        location: referrer_path || report_path(@report)
    end

    def remove
      @report = find_and_authorize_report
      @referrer_path = referrer_path || report_path(@report)
    end

    def destroy
      @report = find_and_authorize_report
      service = Reports::StateService.new(@report)
      result  = service.unapprove

      # FYI: If we implement the remove template, we'll have to
      # replace referrer_path by redirect_path
      #
      respond_with result,
        flash: true,
        location: referrer_path || report_path(@report)
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
