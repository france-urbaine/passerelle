# frozen_string_literal: true

module Users
  class OfficePolicy < ApplicationPolicy
    def index?
      super_admin? || ddfip_admin?
    end

    def switch_ddfip?
      super_admin?
    end
  end
end
