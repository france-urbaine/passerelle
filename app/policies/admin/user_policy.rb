# frozen_string_literal: true

module Admin
  class UserPolicy < ApplicationPolicy
    alias_rule :index?, :new?, :create?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def manage?
      super_admin?
    end

    def reset?
      manage? && user != record
    end

    relation_scope do |relation|
      if super_admin?
        relation.kept
      else
        relation.none
      end
    end

    relation_scope :destroyable do |relation, exclude_current: true|
      relation = authorized(relation, with: self.class)
      relation = relation.where.not(id: user) if exclude_current
      relation
    end

    relation_scope :undiscardable do |relation|
      relation = authorized(relation, with: self.class)
      relation.with_discarded.discarded
    end

    params_filter do |params|
      return unless super_admin?

      params.permit(
        :organization_type, :organization_id, :organization_data, :organization_name,
        :first_name, :last_name, :email,
        :organization_admin, :super_admin, :form_admin, :office_user,
        user_form_types_attributes: %i[_destroy id form_type],
        office_users_attributes: %i[_destroy id office_id supervisor]
      )
    end
  end
end
