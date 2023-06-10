# frozen_string_literal: true

module DDFIPs
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
        relation
      else
        relation.none
      end
    end

    params_filter do |params|
      if super_admin?
        params.permit(
          :first_name, :last_name, :email,
          :organization_admin, :super_admin,
          office_ids: []
        )
      else
        {}
      end
    end
  end
end
