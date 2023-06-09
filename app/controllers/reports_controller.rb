# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authorize!
  before_action :build_reports_scope
  before_action :authorize_reports_scope
  before_action :build_report,     only: %i[new create]
  before_action :find_report,      only: %i[show edit update]
  before_action :authorize_report, only: %i[show edit update]

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @reports = @reports.kept.strict_loading
    @reports, @pagy = index_collection(@reports, nested: @parent)
  end

  def show
    only_kept! @report

    @report_decorator    = Reports::DecorateService.new(@report)
    @report_completeness = Reports::CheckCompletenessService.new(@report)
    @report_completeness.validate unless @report.transmitted?
  end

  def new
    @report_form = Reports::CreateFormService.new(@report)
    @background_url = referrer_path || parent_path || reports_path
  end

  def create
    service = Reports::CreateService.new(@report, current_user, report_params)
    result  = service.save

    # Initialize a new form Service to re-render the :new template
    @report_form = Reports::CreateFormService.new(@report) if result.failed?

    respond_with result,
      flash: true,
      location: -> { report_path(@report) }
  end

  def edit
    only_kept! @report
    @report_form = Reports::UpdateFormService.new(@report, update_fields_param)
    @background_url = referrer_path || report_path(@report)
  end

  def update
    only_kept! @report

    service = Reports::UpdateService.new(@report, report_params)
    result  = service.save

    # Initialize a new form Service to re-render the :edit template
    @report_form = Reports::UpdateFormService.new(@report, update_fields_param) if result.failed?

    respond_with result,
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

  def update_fields_param
    params.require(:fields)
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
