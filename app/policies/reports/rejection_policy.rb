# frozen_string_literal: true

module Reports
  class RejectionPolicy < ApplicationPolicy
    alias_rule :edit?, :update?, :remove?, :destroy?, to: :manage?
    alias_rule :edit_all?, :update_all?, to: :manage?

    def manage?
      if record == Report
        ddfip_admin? || form_admin?
      elsif record.is_a?(Report)
        administrated_form? &&
          record.kept? &&
          record.out_of_sandbox? &&
          record.ddfip_id == organization.id &&
          record.rejectable?
      end
    end

    relation_scope do |relation|
      if ddfip_admin? || form_admin?
        authorized_scope(relation, with: ::ReportPolicy).rejectable
      else
        relation.none
      end
    end

    params_filter do |params|
      params.permit(:reponse) if ddfip_admin? || form_admin?
    end

    private

    def administrated_form?
      ddfip_admin? || (
        form_admin? && administrated_form_types.include?(record.form_type)
      )
    end
  end
end
