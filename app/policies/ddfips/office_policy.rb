# frozen_string_literal: true

module DDFIPs
  class OfficePolicy < ApplicationPolicy
    alias_rule :new?, :create?, to: :index?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :index?

    def index?
      super_admin?
    end

    def assign_ddfip?
      false
    end

    relation_scope do |relation|
      if super_admin?
        relation.kept
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
      if super_admin?
        params.permit(:name, :action)
      else
        {}
      end
    end
  end
end
