# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authorize!
  before_action :load_and_authorize_parent
  before_action :autocompletion_not_implemented!, only: :index
  before_action :better_view_on_parent, only: :index

  def index
    reports       = build_and_authorize_scope
    reports, pagy = index_collection(reports, nested: @parent)
    transmission  = find_or_initialize_transmission

    render Views::Reports::Index::Component.new(reports, pagy, transmission)
  end

  def show
    report = find_and_authorize_report
    report.acknowledge! if current_organization.is_a?(DDFIP) && !report.acknowledged?

    render Views::Reports::Show::Component.new(report)
  end

  def new
    @report = build_report
    @referrer_path = referrer_path || parent_path || reports_path
  end

  def create
    @report = build_report
    service = Reports::CreateService.new(@report, current_user, report_params)
    result  = service.save

    respond_with result,
      flash: true,
      location: -> { report_path(@report) }
  end

  def edit
    report   = find_and_authorize_report
    form     = params.require(:form)
    referrer = referrer_path || report_path(report)

    render Views::Reports::Edit::Component.new(report, form, referrer:)
  end

  def update
    report   = find_and_authorize_report
    referrer = redirect_path || report_path(report)
    result   = Reports::UpdateService.new(report, report_params).save

    if result.success?
      respond_with result, flash: true, location: referrer
    else
      respond_with result, render: Views::Reports::Acceptances::EditComponent.new(report, referrer:)
    end
  end

  def remove
    @report = find_and_authorize_report
    @referrer_path = referrer_path || report_path(@report)
    @redirect_path = @referrer_path unless @referrer_path.include?(report_path(@report))
  end

  def destroy
    @report = find_and_authorize_report(allow_discarded: true)
    @report.discard

    respond_with @report,
      flash: true,
      actions: undiscard_action([:undiscard, @parent, @report]),
      location: redirect_path || reports_path
  end

  def undiscard
    @report = find_and_authorize_report(allow_discarded: true)
    @report.undiscard

    respond_with @report,
      flash: true,
      location: redirect_path || referrer_path || reports_path
  end

  def remove_all
    @reports = build_and_authorize_scope(as: :destroyable)
    @reports = filter_collection(@reports)
    @referrer_path = referrer_path || reports_path(**selection_params)
    @redirect_path = referrer_path
  end

  def destroy_all
    @reports = build_and_authorize_scope(as: :destroyable)
    @reports = filter_collection(@reports)
    @reports.quickly_discard_all

    respond_with @reports,
      flash: true,
      actions: undiscard_action([:undiscard_all, @parent, :reports]),
      location: redirect_path || parent_path || reports_path
  end

  def undiscard_all
    @reports = build_and_authorize_scope(as: :undiscardable)
    @reports = filter_collection(@reports)
    @reports.quickly_undiscard_all

    respond_with @reports,
      flash: true,
      location: redirect_path || referrer_path || parent_path || reports_path
  end

  private

  def load_and_authorize_parent
    # Override this method to load a @parent variable
  end

  def build_and_authorize_scope(as: :default)
    authorized(Report.all, as:).strict_loading
  end

  def build_report(...)
    build_and_authorize_scope.build(...)
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

  def find_or_initialize_transmission
    return unless current_user.organization.is_a?(Collectivity)

    current_user.transmissions.find_or_create_by(
      completed_at: nil,
      collectivity: current_user.organization
    )
  end
end
