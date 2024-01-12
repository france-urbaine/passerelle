# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :remove?, :undiscard?, to: :destroy?
  alias_rule :remove_all?, :undiscard_all?, to: :destroy_all?

  def index?
    user? || dgfip?
  end

  def create?
    collectivity?
  end

  def show?
    if record == Report
      user?
    elsif record.is_a?(Report)
      report_shown_to_collectivity?(record) ||
        report_shown_to_publisher?(record) ||
        report_shown_to_ddfip_admin?(record) ||
        report_shown_to_office_user?(record) ||
        report_shown_to_dgfip?(record)
    end
  end

  def update?
    if record == Report
      user? && !dgfip?
    elsif record.is_a?(Report)
      report_updatable_by_collectivity?(record) ||
        report_updatable_by_publisher?(record) ||
        report_updatable_by_ddfip_admin?(record) ||
        report_updatable_by_office_user?(record)
    end
  end

  def approve?
    allowed_to?(:manage?, record, with: ::Reports::ApprovalPolicy)
  end

  def transmit?
    report_transmissible_by_collectivity?(record) if record.is_a?(Report)
  end

  def assign?
    allowed_to?(:manage?, record, with: ::Reports::AssignmentPolicy)
  end

  def deny?
    allowed_to?(:manage?, record, with: ::Reports::DenialPolicy)
  end

  def destroy?
    if record == Report
      collectivity? || publisher?
    elsif record.is_a?(Report)
      report_destroyable_by_collectivity?(record) ||
        report_destroyable_by_publisher?(record)
    end
  end

  def destroy_all?
    collectivity? || publisher?
  end

  relation_scope do |relation|
    if collectivity?
      relation.merge(reports_listed_to_collectivity)
    elsif publisher?
      relation.merge(reports_listed_to_publisher)
    elsif ddfip_admin?
      relation.merge(reports_listed_to_ddfip_admins)
    elsif dgfip?
      relation.merge(reports_listed_to_dgfip)
    elsif office_user?
      relation.merge(reports_listed_to_office_users)
    else
      relation.none # :nocov:
    end
  end

  relation_scope :destroyable do |relation|
    if collectivity?
      relation.merge(reports_destroyable_by_collectivity)
    elsif publisher?
      relation.merge(reports_destroyable_by_publisher)
    else
      relation.none
    end
  end

  relation_scope :undiscardable do |relation|
    if collectivity?
      relation.merge(reports_undiscardable_by_collectivity)
    elsif publisher?
      relation.merge(reports_undiscardable_by_publisher)
    else
      relation.none
    end
  end

  params_filter do |params|
    if collectivity?
      attributes = %i[form_type priority code_insee date_constat enjeu observations anomalies]
      attributes << { anomalies: [] }
      attributes << { exonerations_attributes: %i[id _destroy status code label base code_collectivite] }
      attributes += Report.column_names.grep(/^(situation|proposition)_/).map(&:to_sym)

      params.permit(*attributes)
    elsif office_user?
      params.permit(:reponse)
    end
  end

  private

  # Authorizations for collectivities
  # ----------------------------------------------------------------------------
  concerning :Collectivities do
    def report_shown_to_collectivity?(report)
      # Discarded reports are not listed but are still accessible
      #
      collectivity? &&
        report.out_of_sandbox? &&
        report.made_by_collectivity?(organization) &&
        (report.made_through_web_ui? || report.transmitted?)
    end

    def report_updatable_by_collectivity?(report)
      collectivity? &&
        report.out_of_sandbox? &&
        report.packing? &&
        report.made_by_collectivity?(organization) &&
        report.made_through_web_ui? &&
        !report.in_active_transmission?
    end

    def report_destroyable_by_collectivity?(report)
      collectivity? &&
        report.out_of_sandbox? &&
        report.packing? &&
        report.made_by_collectivity?(organization) &&
        report.made_through_web_ui?
    end

    def report_transmissible_by_collectivity?(report)
      collectivity? &&
        report.transmissible? &&
        report.made_by_collectivity?(organization)
    end

    def reports_listed_to_collectivity
      return Report.none unless collectivity?

      # Collectivities can list all reports they've packed through the web UI and
      # those fully transmitted by their publishers.
      #
      Report
        .kept
        .out_of_sandbox
        .made_by_collectivity(organization)
        .transmitted_or_made_through_web_ui
    end

    def reports_destroyable_by_collectivity
      return Report.none unless collectivity?

      Report
        .kept
        .out_of_sandbox
        .packing
        .made_by_collectivity(organization)
        .made_through_web_ui
    end

    def reports_undiscardable_by_collectivity
      return Report.none unless collectivity?

      Report
        .discarded
        .out_of_sandbox
        .packing
        .made_by_collectivity(organization)
        .made_through_web_ui
    end
  end

  # Authorizations for publishers
  # ----------------------------------------------------------------------------
  concerning :Publishers do
    def report_shown_to_publisher?(report)
      # Discarded reports are not listed but are still accessible
      #
      publisher? &&
        report.made_by_publisher?(organization) &&
        report.made_through_publisher_api?
    end

    def report_updatable_by_publisher?(report)
      publisher? &&
        report.packing? &&
        report.made_by_publisher?(organization) &&
        report.made_through_publisher_api?
    end

    def report_destroyable_by_publisher?(report)
      publisher? &&
        report.packing? &&
        report.made_by_publisher?(organization) &&
        report.made_through_publisher_api?
    end

    def reports_listed_to_publisher
      return Report.none unless publisher?

      # Publisher can only list reports they packed through their API.
      # It excludes those packed though the web UI by their owned collectivities.
      #
      # The scope `packed_through_publisher_api` is implied by `made_by_publisher`
      # and will be redundant if added.
      #
      Report
        .kept
        .made_by_publisher(organization)
    end

    def reports_destroyable_by_publisher
      return Report.none unless publisher?

      Report
        .kept
        .packing
        .made_by_publisher(organization)
    end

    def reports_undiscardable_by_publisher
      return Report.none unless publisher?

      Report
        .discarded
        .packing
        .made_by_publisher(organization)
    end
  end

  # Authorizations for DGFIPs
  # ----------------------------------------------------------------------------
  concerning :DGFIPs do
    def report_shown_to_dgfip?(report)
      # Discarded reports are not listed but are still accessible
      #
      dgfip? &&
        report.out_of_sandbox? &&
        report.transmitted?
    end

    def reports_listed_to_dgfip
      return Report.none unless dgfip?

      Report
        .kept
        .out_of_sandbox
        .transmitted
    end
  end

  # Authorizations for DDFIPs
  # ----------------------------------------------------------------------------
  concerning :DDFIPAdmins do
    def report_shown_to_ddfip_admin?(report)
      # Denied reports are not listed but are still accessible
      #
      ddfip_admin? &&
        report.out_of_sandbox? &&
        report.transmitted? &&
        report.ddfip == organization
    end

    def report_updatable_by_ddfip_admin?(report)
      ddfip_admin? &&
        report.out_of_sandbox? &&
        report.kept? &&
        report.undenied? &&
        report.ddfip_id == user.organization_id
    end

    def reports_listed_to_ddfip_admins
      return Report.none unless ddfip_admin?

      Report
        .kept
        .out_of_sandbox
        .transmitted
        .transmitted_to_ddfip(organization)
    end
  end

  # Authorizations for office users
  # ----------------------------------------------------------------------------
  concerning :OfficeUsers do
    def report_shown_to_office_user?(report)
      office_user? &&
        report.out_of_sandbox? &&
        report.assigned? &&
        report.covered_by_offices?(user.offices)
    end

    def report_updatable_by_office_user?(report)
      report_shown_to_office_user?(report)
    end

    def reports_listed_to_office_users
      return Report.none unless office_user?

      Report
        .kept
        .assigned
        .out_of_sandbox
        .assigned_to_office(user.offices)
    end
  end
end
