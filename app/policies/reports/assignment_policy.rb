# frozen_string_literal: true

module Reports
  class AssignmentPolicy < ApplicationPolicy
    alias_rule :edit?, :update?, :destroy?, to: :manage?

    def manage?
      if record == Report
        ddfip_admin?
      elsif record.is_a?(Report)
        ddfip_admin? &&
          record.kept? &&
          record.out_of_sandbox? &&
          record.unresolved?
      end
    end

    params_filter do |params|
      params.permit(:office_id) if ddfip_admin?
    end
  end
end
