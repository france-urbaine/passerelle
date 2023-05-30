# frozen_string_literal: true

module Offices
  class CollectivityPolicy < ApplicationPolicy
    def index?
      super_admin? || (organization_admin? && organization.is_a?(DDFIP))
    end

    relation_scope do |relation|
      if super_admin? || (organization_admin? && organization.is_a?(DDFIP))
        relation
      else
        relation.none
      end
    end
  end
end
