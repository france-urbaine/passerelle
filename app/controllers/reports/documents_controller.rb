# frozen_string_literal: true

module Reports
  class DocumentsController < ApplicationController
    include ActiveStorage::SetCurrent

    def show
      @report = find_and_authorize_report(to: :show?)
      @document = @report.documents.find(params[:id])

      url = @document.url(disposition: params[:disposition], virtual_host: true)

      redirect_to url, allow_other_host: true
    end

    def new
      @report = find_and_authorize_report(to: :update?)
      @referrer_path = referrer_path || report_path(@report)
    end

    def create
      @report = find_and_authorize_report(to: :update?)
      @report.documents.attach(params[:documents])

      respond_with @report,
        flash: true,
        location: -> { report_path(@report) }
    end

    def remove
      @report = find_and_authorize_report(to: :update?)
      @document = @report.documents.find(params[:id])

      respond_with @document
    end

    def destroy
      @report = find_and_authorize_report(to: :update?)
      @document = @report.documents.find(params[:id])
      @document.purge_later

      respond_with @document,
        flash: true,
        location: -> { report_path(@report) }
    end

    private

    def find_and_authorize_report(to: :show?)
      report = Report.find(params[:report_id])

      authorize! report, to: to, with: ReportPolicy
      only_kept! report

      report
    end
  end
end
