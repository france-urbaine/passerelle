# frozen_string_literal: true

module Packages
  class ApprovalPolicy < ApplicationPolicy
    def manage?
      if record == Package
        ddfip_admin?
      elsif record.is_a?(Package)
        ddfip_admin? &&
          record.kept? &&
          record.out_of_sandbox? &&
          record.transmitted? &&
          record.reports.covered_by_ddfip(organization).any?
      end
    end
  end
end
