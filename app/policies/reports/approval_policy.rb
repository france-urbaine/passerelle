# frozen_string_literal: true

module Reports
  class ApprovalPolicy < ApplicationPolicy
    def manage?
      if record == Report
        ddfip?
      elsif record.is_a?(Report)
        ddfip? &&
          record.kept? &&
          record.out_of_sandbox? &&
          record.transmitted? &&
          record.covered_by_ddfip?(organization)
      end
    end
  end
end