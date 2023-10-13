# frozen_string_literal: true

module API
  module Reports
    class AttachmentsController < ApplicationController
      def create
        @report = find_and_authorize_report
        @report.documents.attach(params[:documents])

        head :no_content
      end

      def destroy
        @report = find_and_authorize_report
        @report.documents.find(params[:id]).purge_later

        head :no_content
      end

      private

      def find_and_authorize_report
        Report.find(params[:report_id]).tap do |report|
          only_kept! report
          forbidden! t(".already_packed") if report.packed?
          authorize! report, to: :attach?, with: API::ReportPolicy
        end
      end
    end
  end
end
