# frozen_string_literal: true

module Users
  class TwoFactorSettingsPolicy < ApplicationPolicy
    alias_rule :create?, to: :manage?

    def manage?
      true
    end
  end
end
