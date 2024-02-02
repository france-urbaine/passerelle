# frozen_string_literal: true

module Reports
  class RejectionPolicy < ApplicationPolicy
    alias_rule :edit?, :update?, :remove?, :destroy?, to: :manage?

    def manage?
      if record == Report
        ddfip?
      elsif record.is_a?(Report)
        ddfip? &&
          record.kept? &&
          record.out_of_sandbox? &&
          record.ddfip_id == organization.id &&
          record.assigned?
      end
    end

    params_filter do |params|
      params.permit(:reponse) if ddfip?
    end
  end
end
