# frozen_string_literal: true

module Collectivities
  class OfficePolicy < ApplicationPolicy
    def index?
      super_admin? || publisher?
    end

    relation_scope do |relation|
      if super_admin? || publisher?
        relation.kept
      else
        relation.none
      end
    end
  end
end
