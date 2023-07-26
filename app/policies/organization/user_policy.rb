# frozen_string_literal: true

module Organization
  class UserPolicy < ApplicationPolicy
    alias_rule :index?, :new?, :create?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def manage?
      if record == User
        organization_admin?
      elsif record.is_a? User
        organization_admin? && organization_match?(record)
      end
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

      attributes = %i[first_name last_name email]
      attributes << :organization_admin if organization_admin?
      attributes << :super_admin        if super_admin?
      attributes << { office_ids: [] }  if organization.is_a?(DDFIP)

      params.permit(*attributes)
    end

    private

    def organization_match?(user)
      user.organization_type == organization.class.name &&
        user.organization_id == organization.id
    end
  end
end
