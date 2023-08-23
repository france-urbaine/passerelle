# frozen_string_literal: true

module Admin
  class DGFIPPolicy < ApplicationPolicy
    alias_rule :index?, :new?, :create?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def manage?
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
      relation = relation.where.not(id: organization) if dgfip? && exclude_current
      relation
    end

    relation_scope :undiscardable do |relation|
      relation = authorized(relation, with: self.class)
      relation.with_discarded.discarded
    end

    params_filter do |params|
      return unless super_admin?

      params.permit(
        :name,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
        :allow_2fa_via_email
      )
    end
  end
end
