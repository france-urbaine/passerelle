# frozen_string_literal: true

module Organization
  class OfficePolicy < ApplicationPolicy
    alias_rule :index?, :new?, :create?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def manage?
      if record == Office
        ddfip_admin?
      elsif record.is_a?(Office)
        ddfip_admin? && record.ddfip_id == organization.id
      end
    end

    relation_scope do |relation|
      if ddfip_admin?
        relation.kept.owned_by(organization)
      else
        relation.none
      end
    end

    relation_scope :destroyable do |relation|
      authorized(relation, with: self.class)
    end

    relation_scope :undiscardable do |relation|
      relation = authorized(relation, with: self.class)
      relation.with_discarded.discarded
    end

    params_filter do |params|
      return unless ddfip_admin?

      params.permit(:name, competences: [])
    end
  end
end
