# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  alias_rule :index?, :create?, to: :manage_collection?
  alias_rule :assign_organization?, :assign_super_admin?, to: :super_admin?

  def manage_collection?
    super_admin? || organization_admin?
  end

  def manage?
    super_admin? ||
      (record == User && organization_admin?) ||
      (record == User && organization.is_a?(Publisher)) ||
      (record.is_a?(User) && admin_of_user_organization?(record)) ||
      (record.is_a?(User) && publisher_of_user_collectivity?(record))
  end

  def assign_organization_admin?
    super_admin? || (organization_admin? && manage?)
  end

  relation_scope do |relation|
    if super_admin?
      relation
    elsif organization_admin?
      relation.owned_by(organization)
    else
      relation.none
    end
  end

  params_filter do |params|
    if super_admin?
      params.permit(
        :organization_type, :organization_id, :organization_data, :organization_name,
        :first_name, :last_name, :email,
        :organization_admin, :super_admin,
        office_ids: []
      )
    elsif organization_admin? && organization.is_a?(DDFIP)
      params.permit(
        :first_name, :last_name, :email,
        :organization_admin,
        office_ids: []
      )
    elsif organization_admin?
      params.permit(
        :first_name, :last_name, :email,
        :organization_admin
      )
    else
      params.permit(
        :first_name, :last_name, :email
      )
    end
  end

  private

  def admin_of_user_organization?(record)
    organization_admin? && record.organization == organization
  end

  def publisher_of_user_collectivity?(record)
    organization.is_a?(Publisher) &&
      record.organization.is_a?(Collectivity) &&
      record.organization.publisher_id == organization.id
  end
end
