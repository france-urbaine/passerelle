# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  alias_rule :new?, :create?, to: :index?
  alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :index?

  def index?
    super_admin? || organization_admin?
  end

  def manage?
    super_admin? ||
      (record == User && organization_admin?) ||
      (record == User && publisher?) ||
      (record.is_a?(User) && admin_of_user_organization?(record)) ||
      (record.is_a?(User) && publisher_of_user_collectivity?(record))
  end

  def assign_organization?
    super_admin?
  end

  def assign_super_admin?
    super_admin?
  end

  def assign_organization_admin?
    super_admin? || (organization_admin? && manage?)
  end

  relation_scope do |relation|
    if super_admin?
      relation.kept
    elsif organization_admin?
      relation.kept.owned_by(organization)
    else
      relation.none
    end
  end

  relation_scope :destroyable do |relation, exclude_current: true|
    relation = authorized(relation)
    relation = relation.where.not(id: user) if exclude_current
    relation
  end

  relation_scope :undiscardable do |relation|
    relation = authorized(relation)
    relation.with_discarded.discarded
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
    elsif publisher?
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
    publisher? &&
      record.organization.is_a?(Collectivity) &&
      record.organization.publisher_id == organization.id
  end
end
