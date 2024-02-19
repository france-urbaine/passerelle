# frozen_string_literal: true

module Reports
  class ConfirmationPolicy < ApplicationPolicy
    alias_rule :edit?, :update?, :remove?, :destroy?, to: :manage?
    alias_rule :edit_all?, :update_all?, to: :manage?

    def manage?
      if record == Report
        ddfip_admin?
      elsif record.is_a?(Report)
        ddfip_admin? &&
          record.kept? &&
          record.out_of_sandbox? &&
          record.ddfip_id == organization.id &&
          record.confirmable?
      end
    end

    relation_scope do |relation|
      if ddfip_admin?
        authorized_scope(relation, with: ::ReportPolicy).confirmable
      else
        relation.none
      end
    end

    params_filter do |_params|
      nil
    end
  end
end
