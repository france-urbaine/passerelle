# frozen_string_literal: true

module Reports
  class DenialPolicy < ApplicationPolicy
    alias_rule :edit?, :update?, :destroy?, to: :manage?

    def manage?
      if record == Report
        ddfip_admin?
      elsif record.is_a?(Report)
        ddfip_admin? &&
          record.kept? &&
          record.out_of_sandbox? &&
          (record.unassigned? ||
            record.denied?)
      end
    end
  end
end
