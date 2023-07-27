# frozen_string_literal: true

module Territories
  class DDFIPPolicy < ApplicationPolicy
    def index?
      super_admin?
    end

    relation_scope do |relation|
      if super_admin?
        relation
      else
        relation.none
      end
    end
  end
end
