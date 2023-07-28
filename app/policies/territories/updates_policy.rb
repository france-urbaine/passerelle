# frozen_string_literal: true

module Territories
  class UpdatesPolicy < ApplicationPolicy
    alias_rule :index?, :show?, :manage?, to: :not_supported
    alias_rule :edit?, to: :update?

    def update?
      super_admin?
    end
  end
end
