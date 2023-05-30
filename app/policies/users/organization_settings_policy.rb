# frozen_string_literal: true

module Users
  class OrganizationSettingsPolicy < ApplicationPolicy
    def manage?
      organization_admin?
    end
  end
end
