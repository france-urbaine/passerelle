# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authorize!
  before_action :build_reports_scope
  before_action :authorize_reports_scope
  before_action :build_report,     only: %i[new create]
  before_action :find_report,      only: %i[show edit remove update destroy undiscard]
  before_action :authorize_report, only: %i[show edit remove update destroy undiscard]

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @reports = @reports.kept.strict_loading
    @reports, @pagy = index_collection(@reports, nested: @parent)
  end

  def show
    only_kept! @report

    @report_decorator = ReportShowDecorator.new(@report)
  end

  def new
    @report_form = ReportCreateForm.new(@report)
    @background_url = referrer_path || parent_path || reports_path
  end

  def edit
    only_kept! @report

    @report_form = ReportUpdateForm.new(@report, params.require(:fields))
    @background_url = referrer_path || parent_path || reports_path
  end

  def create
    @report_form = ReportCreateForm.new(@report, current_user, report_params)
    @report_form.save

    respond_with @report,
      flash: true,
      location: -> { report_path(@report) }
  end

  def update
    only_kept! @report

    @report_form = ReportUpdateForm.new(@report, params.require(:fields), report_params)
    @report_form.save

    respond_with @report,
      flash: true,
      location: -> { report_path(@report) }
  end

  private

  def build_reports_scope
    @reports = Report.all
  end

  def authorize_reports_scope
    @reports = authorized(@reports)
  end

  def build_report
    @report = @reports.build
  end

  def find_report
    @report = Report.find(params[:id])
  end

  def authorize_report
    authorize! @report
  end

  def report_params
    authorized(params.fetch(:report, {}))
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
