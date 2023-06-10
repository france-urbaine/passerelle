# frozen_string_literal: true

module Offices
  class CommunePolicy < ApplicationPolicy
    alias_rule :index?, to: :manage?
    alias_rule :edit_all?, :update_all?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

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
  end
end
