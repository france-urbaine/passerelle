# frozen_string_literal: true

module Admin
  class DGFIPPolicy < ApplicationPolicy
    alias_rule :index?, :new?, :create?, to: :manage?

    def manage?
      super_admin?
    end

    def destroy?
      false
    end

    relation_scope do |relation|
      if super_admin?
        relation.kept
      else
        relation.none
      end
    end

    params_filter do |params|
      return unless super_admin?

      params.permit(
        :name,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
        :allow_2fa_via_email
      )
    end
  end
end
