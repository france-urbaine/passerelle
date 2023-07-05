# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authorize!
  before_action :build_reports_scope
  before_action :authorize_reports_scope
  before_action :build_report, only: %i[new create]

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @reports = @reports.kept.strict_loading
    @reports, @pagy = index_collection(@reports, nested: @parent)

    case [current_organization, current_user.organization_admin?]
    in [Collectivity, *] then @reports.preload!(:commune, :package)
    in [Publisher, *]    then @reports.preload!(:commune, :package, :collectivity)
    in [DDFIP, true]     then @reports.preload!(:commune, :collectivity, :package, :workshop)
    in [DDFIP, false]    then @reports.preload!(:commune, :collectivity, :workshop)
    end
  end

  def show
    @report = find_and_authorize_report
  end

  def new
    @background_url = referrer_path || parent_path || reports_path
  end

  def create
    service = Reports::CreateService.new(@report, current_user, report_params)
    result  = service.save

    respond_with result,
      flash: true,
      location: -> { report_path(@report) }
  end

  def edit
    @report = find_and_authorize_report
    @background_url = referrer_path || report_path(@report)
  end

  def update
    @report = find_and_authorize_report

    service = Reports::UpdateService.new(@report, report_params)
    result  = service.save

    respond_with result,
      flash: true,
      location: -> { report_path(@report) }
  end

  def remove
    @report = find_and_authorize_report
    @background_url = referrer_path || report_path(@report)
  end

  def destroy
    @report = find_and_authorize_report(allow_discarded: true)
    @report.discard

    respond_with @report,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || reports_path
  end

  def undiscard
    @report = find_and_authorize_report(allow_discarded: true)
    @report.undiscard

    respond_with @report,
      flash: true,
      location: redirect_path || referrer_path || reports_path
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

  def find_and_authorize_report(allow_discarded: false)
    report = Report.find(params[:id])

    authorize! report
    only_kept! report unless allow_discarded

    report
  end

  def report_params
    authorized(params.fetch(:report, {}))
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
