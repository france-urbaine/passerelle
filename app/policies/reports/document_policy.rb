# frozen_string_literal: true

module Reports
  class DocumentPolicy < ApplicationPolicy
    alias_rule :edit?, :update?, :remove?, :destroy?, to: :manage?
    alias_rule :edit_all?, :update_all?, to: :manage?

    def show?
      allowed_to?(:show?, record, with: ::ReportPolicy)
    end

    def manage?
      if record == Report
        collectivity?
      elsif record.is_a?(Report)
        collectivity? &&
          record.packing? &&
          record.out_of_sandbox? &&
          record.made_by_collectivity?(organization) &&
          record.made_through_web_ui? &&
          !record.in_active_transmission?
      end
    end
  end
end
