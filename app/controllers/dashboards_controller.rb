# frozen_string_literal: true

class DashboardsController < ApplicationController
  def index
    authorize! with: ReportPolicy
    reports = authorized(Report.all).strict_loading

    render Views::Dashboard::Component.new(reports)
  end
end
