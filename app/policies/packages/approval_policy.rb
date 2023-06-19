# frozen_string_literal: true

module Packages
  class ApprovalPolicy < ApplicationPolicy
    def show?
      ddfip_admin? && allowed_to?(:show?, record, with: ::PackagePolicy)
    end

    def manage?
      ddfip_admin? && allowed_to?(:approve?, record, with: ::PackagePolicy)
    end
  end
end
