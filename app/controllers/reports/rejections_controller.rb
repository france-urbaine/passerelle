# frozen_string_literal: true

module Reports
  class RejectionsController < ApplicationController
    before_action { authorize! Report, with: Reports::RejectionPolicy }

    def edit
      @report = find_and_authorize_report
      @referrer_path = referrer_path || report_path(@report)
    end

    def update
      @report = find_and_authorize_report
      service = Reports::StateService.new(@report)
      result  = service.reject(report_params)

      respond_with result,
        flash: true,
        location: -> { redirect_path || report_path(@report) }
    end

    def remove
      @report = find_and_authorize_report
      @referrer_path = referrer_path || report_path(@report)
    end

    def destroy
      @report = find_and_authorize_report
      service = Reports::StateService.new(@report)
      result  = service.unreject

      # TODO: replace referrer_path by redircet_path
      # if we implement the remove temlate
      #
      respond_with result,
        flash: true,
        location: referrer_path || report_path(@report)
    end

    private

    def find_and_authorize_report
      report = Report.find(params[:report_id])

      authorize! report, with: Reports::RejectionPolicy
      only_kept! report

      report
    end

    def report_params
      input = params.fetch(:report, {})

      authorized input, with: Reports::RejectionPolicy
    end
  end
end
