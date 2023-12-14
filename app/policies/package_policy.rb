# frozen_string_literal: true

class PackagePolicy < ApplicationPolicy
  alias_rule :new?, :create?, :edit?, :update?, :remove?, :destroy?, :undiscard?, to: :not_supported

  def index?
    collectivity? || publisher? || ddfip_admin?
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

  relation_scope do |relation|
    if collectivity?
      relation.merge(packages_listed_to_collectivity)
    elsif publisher?
      relation.merge(packages_listed_to_publisher)
    elsif ddfip_admin?
      relation.merge(packages_listed_to_ddfip_admins)
    elsif ddfip?
      relation.merge(packages_listed_to_ddfip_admins).with_reports(authorized(Report.all))
    else
      relation.none
    end
  end

  params_filter do |params|
    params.permit(:due_on) if collectivity? || publisher?
  end

  private

  # Authorizations for collectivities
  # ----------------------------------------------------------------------------
  concerning :Collectivities do
    def package_shown_to_collectivity?(package)
      collectivity? &&
        package.out_of_sandbox? &&
        package.made_by_collectivity?(organization)
    end

    def packages_listed_to_collectivity
      return Package.none unless collectivity?

      # Collectivities can list all packages they've packed through the web UI
      # and those fully transmitted by their publishers.
      #
      Package
        .kept
        .out_of_sandbox
        .made_by_collectivity(organization)
    end
  end

  # Authorizations for publishers
  # ----------------------------------------------------------------------------
  concerning :Publishers do
    def package_shown_to_publisher?(package)
      publisher? &&
        package.made_by_publisher?(organization)
    end

    def packages_listed_to_publisher
      return Package.none unless publisher?

      # Publisher can only list packages they packed through their API.
      # It excludes those packed though the web UI by their owned collectivities.
      #
      # The scope `packed_through_publisher_api` is implied by `made_by_publisher`
      # and will be redundant if added.
      #
      Package
        .kept
        .made_by_publisher(organization)
    end
  end

  # Authorizations for DDFIPs
  # ----------------------------------------------------------------------------
  concerning :DDFIPs do
    def packages_listed_to_ddfip_admins
      return Package.none unless ddfip_admin?

      Package
        .kept
        .transmitted
        .with_reports(Report.kept.covered_by_ddfip(organization))
    end

    def package_shown_to_ddfip_admin?(package)
      ddfip_admin? &&
        package.kept? &&
        package.transmitted? &&
        package.reports.covered_by_ddfip(organization).any?
    end
  end
end
