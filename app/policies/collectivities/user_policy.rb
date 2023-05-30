# frozen_string_literal: true

module Collectivities
  class UserPolicy < ApplicationPolicy
    alias_rule :index?, :create?, to: :manage_collection?
    alias_rule :assign_super_admin?, to: :super_admin?

    def manage_collection?
      super_admin? || organization.is_a?(Publisher)
    end

    def assign_organization?
      false
    end

    def assign_organization_admin?
      super_admin? || (organization_admin? && organization.is_a?(Publisher))
    end

    relation_scope do |relation|
      if super_admin? || organization.is_a?(Publisher)
        relation
      else
        relation.none
      end
    end

    params_filter do |params|
      if super_admin?
        params.permit(:first_name, :last_name, :email, :organization_admin, :super_admin)
      elsif organization.is_a?(Publisher) && organization_admin?
        params.permit(:first_name, :last_name, :email, :organization_admin)
      elsif organization.is_a?(Publisher)
        params.permit(:first_name, :last_name, :email)
      else
        {}
      end
    end
  end
end
