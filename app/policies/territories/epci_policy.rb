# frozen_string_literal: true

module Territories
  class EPCIPolicy < ApplicationPolicy
    alias_rule :new?, :create?, :remove?, :destroy?, to: :not_supported
    alias_rule :index?, :show?, to: :manage?

    def manage?
      super_admin?
    end

    relation_scope do |relation|
      relation
    end

    params_filter do |params|
      return unless super_admin?

      params.permit(:name, :siren, :code_departement)
    end
  end
end
