# frozen_string_literal: true

module Users
  class UserSettingsPolicy < ApplicationPolicy
    def manage?
      true
    end
  end
end
