# frozen_string_literal: true

module Users
  class OfficePolicy < ApplicationPolicy
    def index?
      super_admin? || (organization_admin? && organization.is_a?(DDFIP))
    end

    def switch_ddfip?
      super_admin?
    end
  end
end
