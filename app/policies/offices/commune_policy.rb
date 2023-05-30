# frozen_string_literal: true

module Offices
  class CommunePolicy < ApplicationPolicy
    alias_rule :index?, :manage_collection?, to: :manage?

    def manage?
      super_admin? || ddfip_admin?
    end

    relation_scope do |relation|
      if super_admin? || ddfip_admin?
        relation
      else
        relation.none
      end
    end

    private

    def ddfip_admin?
      organization_admin? && organization.is_a?(DDFIP)
    end
  end
end
