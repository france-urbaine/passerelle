# frozen_string_literal: true

module Offices
  class UserPolicy < ApplicationPolicy
    alias_rule :index?, :create?, :assign_organization_admin?, to: :manage_collection?
    alias_rule :assign_super_admin?, to: :super_admin?

    def manage_collection?
      super_admin? || ddfip_admin?
    end

    def manage?
      super_admin? ||
        (record == User && ddfip_admin?) ||
        (record.is_a?(User) && ddfip_admin? && user.organization_id == organization.id)
    end

    relation_scope do |relation|
      if super_admin? || ddfip_admin?
        relation
      else
        relation.none
      end
    end

    params_filter do |params|
      if super_admin?
        params.permit(:first_name, :last_name, :email, :organization_admin, :super_admin)
      elsif ddfip_admin?
        params.permit(:first_name, :last_name, :email, :organization_admin)
      else
        {}
      end
    end

    private

    def ddfip_admin?
      organization_admin? && organization.is_a?(DDFIP)
    end
  end
end
