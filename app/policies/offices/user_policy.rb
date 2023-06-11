# frozen_string_literal: true

module Offices
  class UserPolicy < ApplicationPolicy
    alias_rule :new?, :create?, to: :index?
    alias_rule :edit_all?, :update_all?, to: :index?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :index?

    def index?
      super_admin? || ddfip_admin?
    end

    def manage?
      super_admin? ||
        (record == User && ddfip_admin?) ||
        (record.is_a?(User) && ddfip_admin? && record.organization_id == organization.id)
    end

    def assign_organization?
      false
    end

    def assign_organization_admin?
      super_admin? || ddfip_admin?
    end

    def assign_super_admin?
      super_admin?
    end

    relation_scope do |relation|
      if super_admin?
        relation.kept
      elsif ddfip_admin?
        relation.kept.owned_by(organization)
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
      elsif ddfip_admin?
        params.permit(
          :first_name, :last_name, :email,
          :organization_admin,
          office_ids: []
        )
      end
    end
  end
end
