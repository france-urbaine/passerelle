# frozen_string_literal: true

module Reports
  class ResolutionsController < ApplicationController
    before_action { authorize! Report, with: Reports::ResolutionPolicy }

    def edit
      report   = find_and_authorize_report
      state    = params.require(:state)
      referrer = referrer_path || report_path(report)

      render Views::Reports::Resolutions::EditComponent.new(report, state, referrer:)
    end

    def update
      report   = find_and_authorize_report
      state    = params.require(:state)
      referrer = redirect_path || report_path(report)
      result   = Reports::States::ResolveService.new(report).resolve(state, report_params)

      if result.success?
        respond_with result, flash: true, location: referrer
      else
        respond_with result, render: Views::Reports::Resolutions::EditComponent.new(report, state, referrer:)
      end
    end

    def remove
      report   = find_and_authorize_report
      referrer = referrer_path || report_path(report)

      render Views::Reports::Resolutions::RemoveComponent.new(report, referrer:)
    end

    def destroy
      report   = find_and_authorize_report
      referrer = redirect_path || report_path(report)

      Reports::States::ResolveService.new(report).undo

      respond_with report, flash: true, location: referrer
    end

    private

    def find_and_authorize_report
      report = Report.find(params[:report_id])

      authorize! report, with: Reports::ResolutionPolicy
      only_kept! report

      report
    end

    def report_params
      input = params.fetch(:report, {})

      authorized input, with: Reports::ResolutionPolicy
    end
  end
end
