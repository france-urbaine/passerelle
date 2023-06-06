# frozen_string_literal: true

module Reports
  class AttachmentsController < ApplicationController
    # TODO : Add Policy and authorization
    skip_after_action :verify_authorized
    before_action :find_report, only: %i[new create destroy]

    def new
      only_kept! @report

      @background_url = referrer_path || report_path(@report)
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
  end
end
