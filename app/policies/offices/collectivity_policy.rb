# frozen_string_literal: true

module Offices
  class CollectivityPolicy < ApplicationPolicy
    def index?
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
