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
        relation
      else
        relation.none
      end
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
