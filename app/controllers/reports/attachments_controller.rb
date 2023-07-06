# frozen_string_literal: true

module Reports
  class AttachmentsController < ApplicationController
    before_action :find_report
    before_action :authorize_report

    def new
      @referrer_path = referrer_path || report_path(@report)
    end

    def create
      @report.documents.attach(params[:documents])

      respond_with @report,
        flash: true,
        location: -> { report_path(@report) }
    end

    def destroy
      attachment = @report.documents.find(params[:id])
      attachment.purge

      respond_with @report,
        flash: true,
        location: -> { report_path(@report) }
    end

    private

    def find_report
      @report = Report.find(params[:report_id])
    end

    def authorize_report
      only_kept! @report
      authorize! @report, to: :update?, with: ReportPolicy
    end
  end
end
