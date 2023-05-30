# frozen_string_literal: true

module Collectivities
  class OfficePolicy < ApplicationPolicy
    def index?
      super_admin? || organization.is_a?(Publisher)
    end

    relation_scope do |relation|
      if super_admin? || organization.is_a?(Publisher)
        relation
      else
        relation.none
      end
    end
  end
end
