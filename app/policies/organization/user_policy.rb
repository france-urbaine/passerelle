# frozen_string_literal: true

module Organization
  class UserPolicy < ApplicationPolicy
    alias_rule :index?, to: :show?
    alias_rule :new?, :create?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def show?
      if record == User
        organization_admin?
      elsif record.is_a? User
        organization_admin? && organization_match?(record)
      end
    end

    def manage?
      if record == User
        organization_admin?
      elsif record.is_a? User
        organization_admin? && organization_match?(record) && !record_as_more_privilege_than_current_user(record)
      end
    end

    def reset?
      manage? && (
        (record == User) ||
        (record.is_a?(User) && user != record)
      )
    end

    relation_scope do |relation|
      if organization_admin?
        relation.kept.owned_by(organization)
      else
        relation.none
      end
    end

    relation_scope :destroyable do |relation, exclude_current: true|
      relation = authorized(relation, with: self.class)
      relation = relation.where.not(id: user) if exclude_current
      relation
    end

    relation_scope :undiscardable do |relation|
      relation = authorized(relation, with: self.class)
      relation.with_discarded.discarded
    end

    params_filter do |params|
      return unless organization_admin?

      attributes = %i[first_name last_name email organization_admin]
      attributes << :super_admin        if super_admin?
      attributes << { office_ids: [] }  if organization.is_a?(DDFIP)

      params.permit(*attributes)
    end

    private

    def organization_match?(user)
      user.organization_type == organization.class.name &&
        user.organization_id == organization.id
    end

    def record_as_more_privilege_than_current_user(other)
      other.super_admin? && !user.super_admin?
    end
  end
end
