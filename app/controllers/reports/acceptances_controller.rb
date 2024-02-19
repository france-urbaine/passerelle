# frozen_string_literal: true

module Reports
  class AcceptancesController < ApplicationController
    before_action { authorize! Report, with: Reports::AcceptancePolicy }

    def edit
      report   = find_and_authorize_report
      referrer = referrer_path || report_path(report)

      render Views::Reports::Acceptances::EditComponent.new(report, referrer:)
    end

    def update
      report   = find_and_authorize_report
      referrer = redirect_path || report_path(report)
      result   = Reports::States::AcceptService.new(report).accept(report_params)

      if result.success?
        respond_with result, flash: true, location: referrer
      else
        respond_with result, render: Views::Reports::Acceptances::EditComponent.new(report, referrer:)
      end
    end

    def remove
      report   = find_and_authorize_report
      referrer = referrer_path || report_path(report)

      render Views::Reports::Acceptances::RemoveComponent.new(report, referrer:)
    end

    def destroy
      report   = find_and_authorize_report
      referrer = redirect_path || report_path(report)

      Reports::States::AcceptService.new(report).undo

      respond_with report, flash: true, location: referrer
    end

    def edit_all
      reports  = authorize_reports_scope
      reports  = filter_collection(reports)
      selected = selected_count
      referrer = referrer_path || reports_path

      render Views::Reports::Acceptances::EditAllComponent.new(reports, selected:, referrer:)
    end

    def update_all
      reports  = authorize_reports_scope
      reports  = filter_collection(reports)
      referrer = redirect_path || reports_path

      service = Reports::States::AcceptAllService.new(reports)
      result  = service.accept(report_params)

      if result.success?
        respond_with result, flash: true, location: referrer
      else
        selected = selected_count
        respond_with result,
          render: Views::Reports::Acceptances::EditAllComponent.new(reports, service:, selected:, referrer:)
      end
    end

    private

    def authorize_reports_scope(reports = Report.all, **)
      authorized(reports, with: Reports::AcceptancePolicy, **).strict_loading
    end

    def selected_count
      selected = authorize_reports_scope(with: ReportPolicy)
      selected = filter_collection(selected)
      selected.count
    end

    def find_and_authorize_report
      report = Report.find(params[:report_id])

      authorize! report, with: Reports::AcceptancePolicy
      only_kept! report

      report
    end

    def report_params
      input = params.fetch(:report, {})

      authorized input, with: Reports::AcceptancePolicy
    end
  end
end
