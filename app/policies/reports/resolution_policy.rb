# frozen_string_literal: true

module Reports
  class ResolutionPolicy < ApplicationPolicy
    alias_rule :edit?, :update?, :remove?, :destroy?, to: :manage?
    alias_rule :edit_all?, :update_all?, to: :manage?

    def manage?
      if record == Report
        ddfip?
      elsif record.is_a?(Report)
        ddfip? &&
          record.kept? &&
          record.out_of_sandbox? &&
          record.ddfip_id == organization.id &&
          record.resolvable?
      end
    end

    relation_scope do |relation|
      if ddfip?
        authorized_scope(relation, with: ::ReportPolicy).resolvable
      else
        relation.none
      end
    end

    params_filter do |params|
      params.permit(:reponse, :resolution_motif) if ddfip?
    end
  end
end
