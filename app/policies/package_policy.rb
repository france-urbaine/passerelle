# frozen_string_literal: true

class PackagePolicy < ApplicationPolicy
  alias_rule :edit?, to: :update?
  alias_rule :remove?, :undiscard?, to: :destroy?
  alias_rule :remove_all?, :undiscard_all?, to: :destroy_all?

  def index?
    collectivity? || publisher? || ddfip_admin?
  end

  def create?
    collectivity?
  end

  def show?
    if record == Package
      collectivity? || publisher? || ddfip_admin?
    elsif record.is_a?(Package)
      package_shown_to_collectivity?(record) ||
        package_shown_to_publisher?(record) ||
        package_shown_to_ddfip_admin?(record)
    end
  end

  def update?
    if record == Package
      collectivity? || publisher? || ddfip_admin?
    elsif record.is_a?(Package)
      package_updatable_by_collectivity?(record) ||
        package_updatable_by_publisher?(record) ||
        package_updatable_by_ddfip_admin?(record)
    end
  end

  def destroy?
    if record == Package
      collectivity? || publisher?
    elsif record.is_a?(Package)
      package_destroyable_by_collectivity?(record) ||
        package_destroyable_by_publisher?(record)
    end
  end

  def destroy_all?
    collectivity? || publisher?
  end

  relation_scope do |relation|
    if collectivity?
      relation.merge(packages_listed_to_collectivity)
    elsif publisher?
      relation.merge(packages_listed_to_publisher)
    elsif ddfip_admin?
      relation.merge(packages_listed_to_ddfip_admins)
    else
      relation.none
    end
  end

  relation_scope :to_pack do |relation, report: nil|
    if collectivity?
      relation.merge(packages_to_pack_report_by_collectivity(report))
    elsif publisher?
      relation.merge(packages_to_pack_report_by_publisher(report))
    else
      relation.none
    end
  end

  relation_scope :destroy_all do |relation|
    if collectivity?
      relation.merge(packages_destroyable_by_collectivity)
    elsif publisher?
      relation.merge(packages_destroyable_by_publisher)
    else
      relation.none
    end
  end

  params_filter do |params|
    if collectivity? || publisher?
      params.permit(:name)
    elsif ddfip_admin?
      params.permit(:approved_at, :rejected_at)
    else
      {}
    end
  end

  private

  # Categorize current situation
  # ----------------------------------------------------------------------------
  def collectivity?
    organization.is_a?(Collectivity)
  end

  def publisher?
    organization.is_a?(Publisher)
  end

  def ddfip_admin?
    organization.is_a?(DDFIP) && organization_admin?
  end

  # List packages that can be listed to an user
  # ----------------------------------------------------------------------------
  def packages_listed_to_collectivity
    return Package.none unless collectivity?

    # Collectivities can see all packages they've packed through the web UI and
    # those fully transmitted by their publishers
    #
    Package
      .distinct
      .left_joins(:reports)
      .kept
      .sent_by_collectivity(organization)
      .merge(
        Package.packed_through_web_ui
          .or(Package.transmitted.merge(Report.out_of_sandbox))
      )
  end

  def packages_listed_to_publisher
    return Package.none unless publisher?

    # Publisher can only see packages they packed through their API.
    # It excludes those packed though the web UI by their owned collectivities.
    #
    # The scope `packed_through_publisher_api` is implied by `sent_by_publisher`
    # and will be redundant if added.
    #
    Package.kept.sent_by_publisher(organization)
  end

  def packages_listed_to_ddfip_admins
    return Package.none unless ddfip_admin?

    Package
      .kept
      .unrejected
      .with_reports(Report.covered_by_ddfip(organization).out_of_sandbox)
  end

  # Assert if a package can be shown to an user
  # ----------------------------------------------------------------------------
  def package_shown_to_collectivity?(package)
    collectivity? &&
      package.sent_by_collectivity?(organization) &&
      (
        package.packed_through_web_ui? || (
          package.transmitted? && package.reports.out_of_sandbox.any?
        )
      )
  end

  def package_shown_to_publisher?(package)
    publisher? &&
      package.sent_by_publisher?(organization) &&
      package.packed_through_publisher_api?
  end

  def package_shown_to_ddfip_admin?(package)
    ddfip_admin? &&
      package.kept? &&
      package.unrejected? &&
      package.reports.out_of_sandbox.covered_by_ddfip(organization).any?
  end

  # List packages that can receive reports by an user
  # ----------------------------------------------------------------------------
  def packages_to_pack_report_by_collectivity(report)
    return Package.none unless collectivity? && organization == report.collectivity

    Package.kept.packing
      .sent_by_collectivity(organization)
      .packed_through_web_ui
      .where(action: report.action)
  end

  def packages_to_pack_report_by_publisher(report)
    return Package.none unless publisher? && organization == report.publisher

    Package.kept.packing
      .sent_by_publisher(organization)
      .sent_by_collectivity(report.collectivity)
      .where(action: report.action)
  end

  # Assert if a package can be updated by an user
  # ----------------------------------------------------------------------------
  def package_updatable_by_collectivity?(package)
    collectivity? &&
      package.sent_by_collectivity?(organization) &&
      package.packed_through_web_ui? &&
      package.packing?
  end

  def package_updatable_by_publisher?(package)
    publisher? &&
      package.sent_by_publisher?(organization) &&
      package.packed_through_publisher_api? &&
      package.packing?
  end

  def package_updatable_by_ddfip_admin?(package)
    package_shown_to_ddfip_admin?(package)
  end

  # List packages that can be destroyed by an user
  # ----------------------------------------------------------------------------
  def packages_destroyable_by_collectivity
    return Package.none unless collectivity?

    Package
      .kept
      .sent_by_collectivity(organization)
      .packed_through_web_ui
      .packing
  end

  def packages_destroyable_by_publisher
    return Package.none unless publisher?

    Package
      .kept
      .sent_by_publisher(organization)
      .packing
  end

  # Assert if a package can be destroyed by an user
  # ----------------------------------------------------------------------------
  def package_destroyable_by_collectivity?(package)
    collectivity? &&
      package.sent_by_collectivity?(organization) &&
      package.packed_through_web_ui? &&
      package.packing?
  end

  def package_destroyable_by_publisher?(package)
    publisher? &&
      package.sent_by_publisher?(organization) &&
      package.packed_through_publisher_api? &&
      (package.packing? || package.reports.out_of_sandbox.none?)
  end
end
