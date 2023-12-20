# frozen_string_literal: true

class DashboardsController < ApplicationController
  def index
    authorize! with: ReportPolicy
    @reports = authorized(Report.preload(:office, :ddfip).all).strict_loading.limit(10)
  end
end
