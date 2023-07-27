# frozen_string_literal: true

module Territories
  class CommunePolicy < ApplicationPolicy
    alias_rule :index?, :show?, to: :manage?

    def manage?
      super_admin?
    end

    alias_rule :new?, :create?, :remove?, :destroy?, to: :not_supported

    def not_supported
      false
    end

    relation_scope do |relation|
      relation
    end

    params_filter do |params|
      return unless super_admin?

      params.permit(:name, :code_insee, :code_departement, :siren_epci, :qualified_name)
    end
  end
end
