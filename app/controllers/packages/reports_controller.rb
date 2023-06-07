# frozen_string_literal: true

module Packages
  class ReportsController < ::ReportsController
    private

    def build_reports_scope
      package = Package.find(params[:package_id])

      authorize! package, to: :show?
      only_kept! package

      @parent  = package
      @reports = package.reports
    end
  end
end
