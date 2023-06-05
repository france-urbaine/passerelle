# frozen_string_literal: true

class PackagePolicy < ApplicationPolicy
  alias_rule :index?, to: :manage?

  def index?
    super_admin? ||
      organization.is_a?(Collectivity) ||
      organization.is_a?(Publisher) ||
      (organization.is_a?(DDFIP) && organization_admin?)
  end

  def create?
    organization.is_a?(Collectivity)
  end

  def manage?
    return true if super_admin?

    (record == Package && index?) ||
      (record.is_a?(Package) && package_managed_by_collectivity_user?(record)) ||
      (record.is_a?(Package) && package_managed_by_publisher_user?(record)) ||
      (record.is_a?(Package) && package_managed_by_ddfip_user?(record))
  end

  relation_scope do |relation|
    # TODO
    relation.available_to(organization)
  end

  params_filter do |params|
    # TODO
    params.permit!
  end

  private

  def package_managed_by_collectivity_user?(record)
    organization.is_a?(Collectivity) && record.collectivity == organization
  end

  def package_managed_by_publisher_user?(record)
    organization.is_a?(Publisher) && record.collectivity.publisher == organization
  end

  def package_managed_by_ddfip_user?(record)
    organization.is_a?(DDFIP) &&
      organization_admin? &&
      record.reports.available_to(organization).exist?
  end
end
