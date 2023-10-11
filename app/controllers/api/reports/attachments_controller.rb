# frozen_string_literal: true

module API
  module Reports
    class AttachmentsController < ApplicationController
      before_action :find_report
      before_action :authorize_report

      def create
        @report.documents.attach(params[:documents])

        respond_with @report
      end

      def destroy
        attachment = @report.documents.find(params[:id])
        attachment.purge

        head :no_content
      end

      private

      def find_report
        @report = Report.find(params[:report_id])
      end

      def authorize_report
        only_kept! @report
        authorize! @report, to: :attach?, with: ReportPolicy
      end
    end
  end
end
