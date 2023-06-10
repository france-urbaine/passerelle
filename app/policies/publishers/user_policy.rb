# frozen_string_literal: true

module Publishers
  class UserPolicy < ApplicationPolicy
    alias_rule :new?, :create?, to: :index?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :index?

    def index?
      super_admin?
    end

    def assign_organization?
      false
    end

    def assign_organization_admin?
      super_admin?
    end

    def assign_super_admin?
      super_admin?
    end

    relation_scope do |relation|
      if super_admin?
        relation.kept
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
      if super_admin?
        params.permit(
          :first_name, :last_name, :email,
          :organization_admin, :super_admin
        )
      end
    end
  end
end
