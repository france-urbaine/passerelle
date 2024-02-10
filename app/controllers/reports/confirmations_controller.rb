# frozen_string_literal: true

module Reports
  class ConfirmationsController < ApplicationController
    before_action { authorize! Report, with: Reports::ConfirmationPolicy }

    def edit
      report   = find_and_authorize_report
      referrer = referrer_path || report_path(report)

      render Views::Reports::Confirmations::EditComponent.new(report, referrer:)
    end

    def update
      report   = find_and_authorize_report
      referrer = redirect_path || report_path(report)
      result   = Reports::States::ConfirmService.new(report).confirm(report_params)

      if result.success?
        respond_with result, flash: true, location: referrer
      else
        respond_with result, render: Views::Reports::Confirmations::EditComponent.new(report, referrer:)
      end
    end

    def remove
      report   = find_and_authorize_report
      referrer = referrer_path || report_path(report)

      render Views::Reports::Confirmations::RemoveComponent.new(report, referrer:)
    end

    def destroy
      report   = find_and_authorize_report
      referrer = redirect_path || report_path(report)
      result   = Reports::States::ConfirmService.new(report).undo

      if result.success?
        respond_with result, flash: true, location: referrer
      else
        respond_with result, render: Views::Reports::Confirmations::RemoveComponent.new(report, referrer:)
      end
    end

    private

    def find_and_authorize_report
      report = Report.find(params[:report_id])

      authorize! report, with: Reports::ConfirmationPolicy
      only_kept! report

      report
    end

    def report_params
      input = params.fetch(:report, {})

      authorized input, with: Reports::ConfirmationPolicy
    end
  end
end
